package dev.q20.facade;

import android.app.Activity;
import android.app.Application;
import android.app.Instrumentation;
import android.content.ContentValues;
import android.content.Context;
import android.content.ComponentName;
import android.content.ContentResolver;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ClipData;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.ProviderInfo;
import android.content.pm.ResolveInfo;
import android.database.Cursor;
import android.net.Uri;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.os.Binder;
import android.os.Build;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Handler;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import android.os.Process;
import android.os.SystemClock;
import android.os.Trace;
import android.text.BoringLayout;
import android.text.DynamicLayout;
import android.text.Layout;
import android.text.SpannableStringBuilder;
import android.text.StaticLayout;
import android.text.TextPaint;
import android.system.Os;
import android.util.TypedValue;
import android.view.Display;
import android.view.InputDevice;
import android.view.MotionEvent;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.Surface;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ListView;
import android.view.animation.PathInterpolator;
import android.widget.EditText;
import android.widget.TextView;

import org.xmlpull.v1.XmlPullParser;

import java.io.File;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Our own app launcher for the Q20: the seed of an ActivityThread replacement.
 * Runs an unmodified APK's Activity headless under bare dalvikvm, with no
 * system_server and no binder driver (the A ladder, docs/apk-milestones.md).
 *
 * Usage: Launcher <mode> <apk> <activity class>
 * Modes, each a runnable check of one facade layer:
 *   props  build.prop properties, ICU locale data, Character natives
 *   res    framework-res and the APK's own resources through libandroidfw
 *   looper Looper/Handler message pump on poll, Binder and Trace statics
 *   gfx    graphics facade: FreeType metrics, Path, RenderNode, ColorFilter
 *   activity  the APK's Activity: fake services, real ContextImpl, lifecycle,
 *          then measure and layout of its window at the Q20 screen size
 *   tap    the Activity, then real MotionEvent taps on the view ids given
 *          after the class, in order; each id=text argument is then checked
 *   draw, live  the Activity on the panel, once or as the resident loop
 */
public final class Launcher {
    private static int passed;
    private static int total;

    public static void main(String[] args) {
        String mode = args.length > 0 ? args[0] : "props";
        String apk = args.length > 1 ? args[1] : null;
        String activityClass = args.length > 2 ? args[2] : null;
        System.out.println("facade: mode " + mode);
        try {
            if (mode.equals("props")) {
                props();
            } else if (mode.equals("res")) {
                res(apk);
            } else if (mode.equals("looper")) {
                looper();
            } else if (mode.equals("gfx")) {
                gfx();
            } else if (mode.equals("activity")) {
                activity(apk, activityClass);
            } else if (mode.equals("draw")) {
                activity(apk, activityClass);
                draw();
            } else if (mode.equals("live")) {
                activity(apk, activityClass);
                draw();
                live();
            } else if (mode.equals("tap")) {
                activity(apk, activityClass);
                taps(java.util.Arrays.copyOfRange(args, 3, args.length));
            } else if (mode.equals("inputtest")) {
                inputTest();
            } else if (mode.equals("scroll")) {
                scroll(apk, activityClass);
            } else if (mode.equals("window")) {
                sRealWindows = true;
                activity(apk, activityClass);
            } else {
                System.out.println("facade: unknown mode " + mode);
                System.exit(2);
            }
        } catch (Throwable t) {
            check(mode + " threw " + rootCause(t), false);
            t.printStackTrace(System.out);
        }
        System.out.println("facade: " + mode + " passed=" + passed + "/" + total);
        System.exit(passed == total ? 0 : 1);
    }

    static void props() {
        check("props SDK_INT=" + Build.VERSION.SDK_INT + " CPU_ABI=" + Build.CPU_ABI,
                Build.VERSION.SDK_INT == 23 && "armeabi-v7a".equals(Build.CPU_ABI));
        String s = String.format(Locale.US, "count: %1$d", 0);
        check("String.format " + s, "count: 0".equals(s));
        check("Character directionality",
                Character.getDirectionality('a') == Character.DIRECTIONALITY_LEFT_TO_RIGHT
                        && Character.getType('A') == Character.UPPERCASE_LETTER
                        && Character.isLetter('é'));
    }

    static void res(String apk) throws Exception {
        long t0 = SystemClock.uptimeMillis();
        Resources sys = Resources.getSystem();
        String ok = sys.getString(android.R.string.ok);
        System.out.println("facade: Resources.getSystem took " + (SystemClock.uptimeMillis() - t0) + " ms");
        check("system string ok=" + ok, "OK".equals(ok));

        AssetManager am = AssetManager.class.newInstance();
        AssetManager.class.getMethod("addAssetPath", String.class).invoke(am, apk);
        Resources app = new Resources(am, sys.getDisplayMetrics(), null);
        String name = app.getString(app.getIdentifier("app_name", "string", "dev.q20.prober"));
        check("app string app_name=" + name, "Prober".equals(name));
        String fmt = app.getString(app.getIdentifier("counter_fmt", "string", "dev.q20.prober"), 0);
        check("app format counter_fmt=" + fmt, "count: 0".equals(fmt));

        XmlResourceParser x = sys.getLayout(android.R.layout.simple_list_item_1);
        int ev;
        while ((ev = x.next()) != XmlPullParser.START_TAG && ev != XmlPullParser.END_DOCUMENT) {}
        check("system xml simple_list_item_1 <" + x.getName() + ">", "TextView".equals(x.getName()));
        x.close();
    }

    static void looper() {
        check("binder identity", Binder.getCallingUid() == Process.myUid()
                && Binder.clearCallingIdentity() == Binder.clearCallingIdentity());
        Trace.beginSection("q20");
        Trace.endSection();
        check("trace sections", true);

        Looper.prepare();
        final Looper looper = Looper.myLooper();
        final Handler h = new Handler(looper);
        final long t0 = SystemClock.uptimeMillis();
        final boolean[] immediate = new boolean[1];
        final long[] cross = new long[1];
        final long[] delayed = new long[1];
        h.post(new Runnable() {
            public void run() { immediate[0] = true; }
        });
        // Lands while the pump sleeps in poll() until the 300 ms message: only the
        // wake pipe gets it run near 100 ms.
        new Thread(new Runnable() {
            public void run() {
                SystemClock.sleep(100);
                h.post(new Runnable() {
                    public void run() { cross[0] = SystemClock.uptimeMillis() - t0; }
                });
            }
        }).start();
        h.postDelayed(new Runnable() {
            public void run() {
                delayed[0] = SystemClock.uptimeMillis() - t0;
                looper.quit();
            }
        }, 300);
        Thread watchdog = new Thread(new Runnable() {
            public void run() {
                SystemClock.sleep(5000);
                System.out.println("facade check: FAIL looper watchdog, pump stuck");
                System.exit(2);
            }
        });
        watchdog.setDaemon(true);
        watchdog.start();
        Looper.loop();
        check("immediate post", immediate[0]);
        check("cross thread wake (" + cross[0] + " ms)", cross[0] >= 100 && cross[0] < 250);
        check("delayed post (" + delayed[0] + " ms)", delayed[0] >= 300);
        check("quit", true);
    }

    static void gfx() throws Exception {
        Paint p = new Paint();
        p.setTextSize(48);
        float h = p.measureText("H");
        Paint.FontMetricsInt fmi = p.getFontMetricsInt();
        System.out.println("facade: paint 48px H=" + h + " ascent=" + fmi.ascent
                + " descent=" + fmi.descent + " top=" + fmi.top + " bottom=" + fmi.bottom);
        check("paint metrics", h > 0 && fmi.ascent < 0 && fmi.descent > 0 && fmi.top <= fmi.ascent);

        TextPaint tp = new TextPaint(Paint.ANTI_ALIAS_FLAG);
        tp.setTextSize(48);
        BoringLayout.Metrics bm = BoringLayout.isBoring("count: 0", tp);
        check("BoringLayout count: 0 width=" + (bm == null ? -1 : bm.width), bm != null && bm.width > 0);

        // A9: StaticLayout through the facade line breaker. The width holds
        // exactly "one two three" (+2 px rounding slack), so that is line 0.
        String words = "one two three four five six";
        int w = (int) tp.measureText("one two three") + 2;
        StaticLayout sl = StaticLayout.Builder.obtain(words, 0, words.length(), tp, w).build();
        boolean fits = sl.getLineEnd(0) == "one two three ".length();
        for (int i = 0; i < sl.getLineCount(); i++) {
            // getLineMax: the extent without trailing spaces, what the breaker bounds
            fits &= sl.getLineMax(i) <= w && (i == 0 || words.charAt(sl.getLineStart(i) - 1) == ' ');
        }
        check("StaticLayout wrap lines=" + sl.getLineCount() + " end0=" + sl.getLineEnd(0),
                sl.getLineCount() > 1 && fits);
        String word = "abcdefghijklmnopqrstuvwxyz";
        StaticLayout split = StaticLayout.Builder.obtain(word, 0, word.length(), tp,
                (int) tp.measureText("abcdefgh")).build();
        boolean progress = true;
        for (int i = 0; i < split.getLineCount(); i++) progress &= split.getLineEnd(i) > split.getLineStart(i);
        check("StaticLayout long word lines=" + split.getLineCount(), split.getLineCount() > 1 && progress
                && split.getLineEnd(split.getLineCount() - 1) == word.length());
        check("StaticLayout empty", StaticLayout.Builder.obtain("", 0, 0, tp, w).build().getLineCount() == 1);
        // EditText's path: a Spannable reflows through DynamicLayout.
        DynamicLayout dl = new DynamicLayout(new SpannableStringBuilder(words), tp, w,
                Layout.Alignment.ALIGN_NORMAL, 1f, 0f, false);
        check("DynamicLayout lines=" + dl.getLineCount(), dl.getLineCount() == sl.getLineCount());

        PathInterpolator pi = new PathInterpolator(0.4f, 0f, 0.2f, 1f);
        float a = pi.getInterpolation(0f), m = pi.getInterpolation(0.5f), z = pi.getInterpolation(1f);
        check("PathInterpolator 0=" + a + " 0.5=" + m + " 1=" + z, a == 0f && z == 1f && m > 0.5f && m < 1f);

        check("PorterDuffColorFilter", new PorterDuffColorFilter(0xff00ff00, PorterDuff.Mode.SRC_IN) != null);

        Class<?> rn = Class.forName("android.view.RenderNode");
        Object node = rn.getMethod("create", String.class, View.class).invoke(null, "q20", null);
        rn.getMethod("setElevation", float.class).invoke(node, 3f);
        float e = (Float) rn.getMethod("getElevation").invoke(node);
        check("RenderNode elevation round trip " + e, e == 3f);
    }

    // ---- activity: our ActivityThread stand in ----

    // Calibration knobs: the Q20 screen (720x720) and its density bucket. The
    // density comes from ro.sf.lcd_density through Resources.getSystem().
    static final int SCREEN_PX = 720;

    static void activity(String apk, String cls) throws Exception {
        Looper.prepareMainLooper();  // ActivityThread.mH and Activity.mHandler need it
        int dpi = Resources.getSystem().getDisplayMetrics().densityDpi;
        installServices(dpi);

        // The real manifest parser fills ApplicationInfo and ActivityInfo.
        Object pkg = call(make("android.content.pm.PackageParser"), "parsePackage", new File(apk), 0);
        ApplicationInfo ai = (ApplicationInfo) get(pkg, "applicationInfo");
        ai.sourceDir = ai.publicSourceDir = apk;
        ai.uid = Os.getuid();
        ai.dataDir = System.getenv("ANDROID_DATA") + "/data/" + ai.packageName;
        new File(ai.dataDir).mkdirs();
        ActivityInfo info = null;
        for (Object a : (List<?>) get(pkg, "activities")) {
            ActivityInfo i = (ActivityInfo) get(a, "info");
            if (i.name.equals(cls)) info = i;
        }
        if (info == null) throw new IllegalArgumentException(cls + " not in " + apk);
        // ponytail: software until A7 brings a renderer.
        info.flags &= ~ActivityInfo.FLAG_HARDWARE_ACCELERATED;

        set(call(Class.forName("android.app.ResourcesManager"), "getInstance"),
                "mResConfiguration", configuration(dpi));
        sPkg = pkg;
        sAi = ai;
        sThread = make("android.app.ActivityThread");
        Object compat = getStatic(Class.forName("android.content.res.CompatibilityInfo"),
                "DEFAULT_COMPATIBILITY_INFO");
        sLoadedApk = make("android.app.LoadedApk", sThread, ai, compat, null, false, false, false);
        // Providers load through the context's loader: the activity's, not a
        // second PathClassLoader over the same APK.
        set(sLoadedApk, "mClassLoader", ClassLoader.getSystemClassLoader());
        sInstr = new FInstr();  // execStartActivity launches the target in-process
        set(sThread, "mInstrumentation", sInstr);  // installProvider's error path
        sContextImpl = Class.forName("android.app.ContextImpl");
        Context appContext = (Context) call(sContextImpl, "createAppContext", sThread, sLoadedApk);
        Application app = Instrumentation.newApplication(Application.class, appContext);
        sApp = app;
        call(appContext, "setOuterContext", app);
        final StringBuilder lifecycle = new StringBuilder();
        app.registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
            public void onActivityCreated(Activity a, Bundle b) { lifecycle.append("created "); }
            public void onActivityStarted(Activity a) { lifecycle.append("started "); }
            public void onActivityResumed(Activity a) { lifecycle.append("resumed "); }
            public void onActivityPaused(Activity a) { lifecycle.append("paused "); }
            public void onActivityStopped(Activity a) { lifecycle.append("stopped "); }
            public void onActivitySaveInstanceState(Activity a, Bundle b) {}
            public void onActivityDestroyed(Activity a) { lifecycle.append("destroyed "); }
        });
        // handleBindApplication's order: the app's providers, then its activity.
        ArrayList<ProviderInfo> providers = new ArrayList<ProviderInfo>();
        for (Object p : (List<?>) get(pkg, "providers")) providers.add((ProviderInfo) get(p, "info"));
        sAppAuthority = providers.isEmpty() ? null : providers.get(0).authority;  // the app's own, for the self-check
        // The "settings" provider the framework assumes is always present (text
        // input reads auto-caps/auto-text through it); load our stub in-process.
        ProviderInfo settings = new ProviderInfo();
        settings.authority = "settings";
        settings.name = "dev.q20.facade.SettingsStub";
        settings.packageName = ai.packageName;
        settings.applicationInfo = ai;
        providers.add(settings);
        // SQLite's page size comes from StatFs("/data"), which QNX denies
        // (EACCES). Calibration knob: 4096, the Q20 eMMC block.
        setStatic(Class.forName("android.database.sqlite.SQLiteGlobal"), "sDefaultPageSize", 4096);
        if (!providers.isEmpty()) call(sThread, "installContentProviders", app, providers);

        Activity act = launch(info, new Intent(Intent.ACTION_MAIN).setClassName(ai.packageName, cls));
        check("lifecycle " + lifecycle.toString().trim(),
                lifecycle.toString().equals("created started resumed "));
        View decor = act.getWindow().getDecorView();
        check("decor " + decor.getWidth() + "x" + decor.getHeight(),
                decor.getWidth() == SCREEN_PX && decor.getHeight() == SCREEN_PX);
        android.app.ActionBar bar = act.getActionBar();
        if (bar != null) {
            check("action bar \"" + bar.getTitle() + "\" height " + bar.getHeight(),
                    bar.isShowing() && bar.getHeight() > 0);
        }
        if (sAppAuthority != null) provider(act, sAppAuthority);
        if (id(act, "counter_text") == 0) return;  // the rest is the Prober's own tree
        TextView counter = (TextView) act.findViewById(id(act, "counter_text"));
        View bump = act.findViewById(id(act, "bump_button"));
        check("counter_text \"" + counter.getText() + "\" " + counter.getWidth() + "x" + counter.getHeight(),
                "count: 0".contentEquals(counter.getText()) && counter.getWidth() > 0);
        check("bump_button " + bump.getWidth() + "x" + bump.getHeight(),
                bump.getWidth() > 0 && bump.getHeight() > 0);
        check("both inside the screen", inside(counter, decor) && inside(bump, decor));
        bump.setElevation(3f);
        check("RenderNode round trip elevation=" + bump.getElevation(), bump.getElevation() == 3f);
    }

    // ---- activity stack (NOD-32): startActivity, Back, in-process ----

    // Set once by activity() so launch()/the resolver can reuse them without a
    // system_server: the ActivityThread, Application, LoadedApk, our
    // Instrumentation, ContextImpl class, the app's ApplicationInfo and parsed
    // package, and the back stack (top is sDecor's activity).
    static Object sThread, sLoadedApk, sContextImpl, sPkg;
    static String sAppAuthority;  // the app's own provider authority, for the self-check
    static Application sApp;
    static Instrumentation sInstr;
    static ApplicationInfo sAi;
    static final Deque<Activity> sStack = new ArrayDeque<Activity>();

    // Create, theme, run through onCreate/Start/Resume, attach and lay out one
    // Activity; push it and make its decor current. The facade's own attach
    // replaces ActivityThread's handleResumeActivity (no system_server), so this
    // serves both the first activity and every startActivity target.
    static Activity launch(ActivityInfo info, Intent intent) throws Exception {
        // Pause and stop the activity being covered, as the real launch does:
        // its managed cursors go stale (mStopped), so a later Back's
        // performRestart requeries them and any rows it changed reappear.
        Activity prev = sStack.peek();
        if (prev != null) {
            call(prev, "performPause");
            call(prev, "performStop");
        }
        info.flags &= ~ActivityInfo.FLAG_HARDWARE_ACCELERATED;  // software until A7's renderer
        Context base = (Context) call(sContextImpl, "createActivityContext", sThread, sLoadedApk, 0, null);
        CharSequence title = info.labelRes != 0 ? base.getResources().getText(info.labelRes) : info.name;
        Activity act = sInstr.newActivity(ClassLoader.getSystemClassLoader().loadClass(info.name), base,
                new Binder(), sApp, intent, info, title, null, null, null);
        // newActivity attaches with a null ActivityThread; Activity.startActivity
        // reads mMainThread.getApplicationThread(), so wire ours in.
        set(act, "mMainThread", sThread);
        call(base, "setOuterContext", act);
        // The manifest theme (activity, else application). With none, the stock
        // default below targetSdk 14 (Theme, Holo); ponytail: above it Material
        // NoActionBar, because DeviceDefault's action bar needs a PackageManager.
        int theme = info.getThemeResource();
        if (theme == 0) {
            theme = sAi.targetSdkVersion < Build.VERSION_CODES.ICE_CREAM_SANDWICH
                    ? (Integer) call(Resources.class, "selectDefaultTheme", 0, sAi.targetSdkVersion)
                    : android.R.style.Theme_Material_NoActionBar;
        }
        act.setTheme(theme);
        sInstr.callActivityOnCreate(act, null);
        call(act, "performStart");
        sInstr.callActivityOnPostCreate(act, null);
        call(act, "performResume");
        // Phase 4: the window at the Q20 screen size, attached the way
        // ViewRootImpl's first traversal does it, then measured and laid out.
        View decor = act.getWindow().getDecorView();
        sDecor = decor;
        if (sRealWindows) {
            attachReal(act, decor);  // NOD-31: real ViewRootImpl drives layout + draw
        } else {
            attach(act, decor);
            layoutPass();
        }
        dump(decor, "", 0, 0);
        sStack.push(act);
        return act;
    }

    static ActivityInfo findActivityInfo(String cls) throws Exception {
        for (Object a : (List<?>) get(sPkg, "activities")) {
            ActivityInfo i = (ActivityInfo) get(a, "info");
            if (i.name.equals(cls)) return i;
        }
        return null;
    }

    // Resolve an intent to one of the package's activities: explicit component,
    // else the first manifest intent-filter that matches (action, data type via
    // ContentResolver.getType, category). IntentFilter.match does the type work.
    static ActivityInfo resolveActivity(Intent intent) throws Exception {
        if (intent.getComponent() != null) return findActivityInfo(intent.getComponent().getClassName());
        ContentResolver cr = sApp.getContentResolver();
        for (Object a : (List<?>) get(sPkg, "activities")) {
            for (Object f : (List<?>) get(a, "intents")) {
                if (((IntentFilter) f).match(cr, intent, true, "facade") >= 0) return (ActivityInfo) get(a, "info");
            }
        }
        return null;
    }

    // Back: finish and tear down the top activity (its onPause is where NoteEditor
    // writes the note), then restart+resume the one beneath so its managed cursors
    // requery and the new row shows.
    static void back() throws Exception {
        if (sStack.size() < 2) { System.out.println("facade: back at root, ignored"); return; }
        Activity top = sStack.pop();
        top.finish();  // isFinishing() so NoteEditor's onPause commits instead of discarding
        call(top, "performPause");
        call(top, "performStop");
        call(top, "performDestroy");
        Activity parent = sStack.peek();
        sDecor = parent.getWindow().getDecorView();
        call(parent, "performRestart");  // requeries managed cursors (the new note)
        call(parent, "performResume");
        layoutPass();
        System.out.println("facade: back to " + parent.getClass().getSimpleName());
    }

    // Our Instrumentation: Activity.startActivity lands in execStartActivity
    // instead of a system_server. The target launches synchronously in-process
    // (startActivityNow's effect without ActivityThread's own window attach).
    static class FInstr extends Instrumentation {
        public ActivityResult execStartActivity(Context who, IBinder contextThread, IBinder token,
                Activity target, Intent intent, int requestCode, Bundle options) {
            try {
                ActivityInfo info = resolveActivity(intent);
                if (info == null) { System.out.println("facade: no activity for " + intent); return null; }
                System.out.println("facade: startActivity " + intent.getAction() + " -> " + info.name);
                // The system fills the resolved component after matching; code
                // downstream (getComponentName) reads it.
                intent.setComponent(new ComponentName(info.packageName, info.name));
                launch(info, intent);
            } catch (Exception e) {
                throw new RuntimeException("startActivity " + intent, e);
            }
            return null;
        }
    }

    // A row through the app's own provider into SQLite and back, removed again
    // so the app's list stays as it was. Assumes NotePad's notes table.
    static void provider(Activity act, String authority) {
        android.content.ContentResolver cr = act.getContentResolver();
        ContentValues v = new ContentValues();
        v.put("title", "q20");
        Uri row = cr.insert(Uri.parse("content://" + authority + "/notes"), v);
        Cursor c = cr.query(row, new String[] { "title" }, null, null, null);
        boolean ok = c != null && c.getCount() == 1 && c.moveToFirst() && "q20".equals(c.getString(0));
        if (c != null) c.close();
        check("provider insert/query " + row, ok);
        check("provider delete", cr.delete(row, null, null) == 1);
    }

    // The AttachInfo ViewRootImpl hands the tree: a main looper Handler, so
    // View.post (click and tap timeout runnables) runs, and the invalidate
    // bookkeeping the live loop reads back through isDirty(). Window and
    // session are logging fakes like the services below. The ViewRootImpl in
    // it is real but never setView()'d: View.postOnAnimation (ViewPager) and
    // RenderNodeAnimator reach through it for its Choreographer and pending
    // animator list. Sound and haptics stay no ops here, because its own
    // need a window session.
    // NOD-31: bring a window up through the real stock path instead of the
    // hand-built attach()/layoutPass()/draw(). makeVisible -> WindowManager.addView
    // -> new ViewRootImpl -> setView -> our IWindowSession.addToDisplay; the
    // ViewRootImpl then measures, lays out and draws (drawSoftware locks the same
    // facade Surface as draw() does). INPUT_FEATURE_NO_INPUT_CHANNEL skips the
    // input channel so no InputChannel/InputEventReceiver natives are needed yet.
    static boolean sRealWindows;
    static void attachReal(Activity act, View decor) throws Exception {
        if (sHandler == null) sHandler = new Handler(Looper.getMainLooper());
        setStatic(Class.forName("android.view.WindowManagerGlobal"), "sWindowSession", windowSession());
        WindowManager.LayoutParams p = act.getWindow().getAttributes();
        // inputFeatures + INPUT_FEATURE_NO_INPUT_CHANNEL (0x2) are hidden from
        // android-23.jar; reflect. Skips the InputChannel so setView needs no
        // input natives until real touch is wired.
        set(p, "inputFeatures", ((Integer) get(p, "inputFeatures")) | 0x2);
        call(act, "makeVisible");        // adds the decor; ViewRootImpl schedules the first traversal
        pumpLooper(500);                 // run it: measure, layout, draw
    }

    // Run the main looper for ms so posted work (the ViewRootImpl traversal via
    // the Choreographer) executes, then stop. Same bounded-loop trick as taps().
    static void pumpLooper(int ms) {
        final RuntimeException stop = new RuntimeException("pump done");
        sHandler.postDelayed(new Runnable() { public void run() { throw stop; } }, ms);
        try {
            Looper.loop();
        } catch (RuntimeException e) {
            if (e != stop) throw e;
        }
    }

    // The real IWindowSession: addToDisplay/relayout succeed with zero insets, a
    // full-screen frame and a valid Surface (mNativeObject != 0, the sentinel the
    // facade's Surface natives accept); getDisplayFrame is the panel; the rest
    // are no-ops. One window needs no more than this.
    static Object windowSession() throws Exception {
        final String iface = "android.view.IWindowSession";
        final Binder binder = new Binder();
        return Proxy.newProxyInstance(Class.forName(iface).getClassLoader(),
                new Class<?>[] { Class.forName(iface) }, new InvocationHandler() {
                    public Object invoke(Object p, Method m, Object[] a) throws Throwable {
                        String n = m.getName();
                        if (n.equals("asBinder")) return binder;
                        if (m.getDeclaringClass() == Object.class) {
                            if (n.equals("equals")) return p == a[0];
                            if (n.equals("hashCode")) return System.identityHashCode(p);
                            return "fake session";
                        }
                        if (n.equals("addToDisplay")) {
                            rectSet(a[5], 0, 0, 0, 0);   // outContentInsets
                            rectSet(a[6], 0, 0, 0, 0);   // outStableInsets
                            rectSet(a[7], 0, 0, 0, 0);   // outOutsets
                            return 0;                    // ADD_OKAY
                        }
                        if (n.equals("relayout")) {
                            rectSet(a[7], 0, 0, SCREEN_PX, SCREEN_PX);  // outFrame
                            for (int i = 8; i <= 12; i++) rectSet(a[i], 0, 0, 0, 0);
                            if (a[14] != null) set(a[14], "mNativeObject", 1L);  // outSurface valid
                            return 0;
                        }
                        if (n.equals("getDisplayFrame")) { rectSet(a[1], 0, 0, SCREEN_PX, SCREEN_PX); return null; }
                        return zero(m.getReturnType());
                    }
                });
    }

    static void rectSet(Object r, int l, int t, int rt, int b) {
        if (r instanceof android.graphics.Rect) ((android.graphics.Rect) r).set(l, t, rt, b);
    }

    static Handler sHandler;
    static void attach(Activity act, View decor) throws Exception {
        sHandler = new Handler(Looper.getMainLooper());
        Object session = serve("session", "android.view.IWindowSession", new HashMap<String, Object>())
                .queryLocalInterface("android.view.IWindowSession");
        Object window = serve("iwindow", "android.view.IWindow", new HashMap<String, Object>())
                .queryLocalInterface("android.view.IWindow");
        Class<?> cb = Class.forName("android.view.View$AttachInfo$Callbacks");
        Object effects = Proxy.newProxyInstance(cb.getClassLoader(), new Class<?>[] { cb },
                new InvocationHandler() {
                    public Object invoke(Object p, Method m, Object[] args) { return zero(m.getReturnType()); }
                });
        Display display = act.getWindowManager().getDefaultDisplay();
        Object root = make("android.view.ViewRootImpl", act, display);
        Object ai = make("android.view.View$AttachInfo", session, window, display, root, sHandler, effects);
        set(ai, "mRootView", decor);
        set(ai, "mApplicationScale", 1f);
        set(ai, "mInTouchMode", true);  // a touch only device, as ViewRootImpl decides on first touch
        call(decor, "dispatchAttachedToWindow", ai, View.VISIBLE);
    }

    static void layoutPass() {
        int spec = View.MeasureSpec.makeMeasureSpec(SCREEN_PX, View.MeasureSpec.EXACTLY);
        sDecor.measure(spec, spec);
        sDecor.layout(0, 0, SCREEN_PX, SCREEN_PX);
    }

    // A7: the laid out tree's first pixels. Surface is the window handle the
    // framework already knows how to drive: lockCanvas maps the Q20 Screen
    // buffer into a Canvas (our JNI in graphics_facade.cc), one draw pass
    // fills it, unlockCanvasAndPost posts it. mNativeObject only has to be
    // non zero: Surface checks it before every call and our natives ignore it.
    static View sDecor;

    // A8 phase 2b: the input half of the live loop. Plain Java BYTE parsing:
    // the compositor publishes ASCII only ("D|M|U x y" lines, seq bumped after
    // the file close), and bytes need no charset decoder per 30 ms poll. A
    // Reader works since A9 (real NativeConverter); this predates it.
    static long sInSeq = -1;  // highest absolute event index consumed
    static int[] q20PollInput() {
        String raw = System.getenv("Q20_DRAW_RAW");
        return raw == null ? new int[0] : q20PollInput(raw);
    }

    // Read the events the compositor published since our cursor. Each .input
    // line is "<idx> <K> <x> <y>" (K in D/M/U), the .input.seq is the running
    // total; we emit only lines whose absolute index is past sInSeq, so no
    // event is replayed and (within the compositor's 32-event ring) none lost.
    static int[] q20PollInput(String raw) {
        try {
            java.io.FileInputStream s = new java.io.FileInputStream(raw + ".input.seq");
            long seq = 0;
            int b;
            while ((b = s.read()) >= 0 && b >= '0' && b <= '9') seq = seq * 10 + (b - '0');
            try { s.close(); } catch (Throwable ignored) { }
            if (seq == sInSeq) return new int[0];  // != also catches compositor restarts
            java.io.FileInputStream f = new java.io.FileInputStream(raw + ".input");
            int[] vals = new int[96];
            int n = 0;
            long maxIdx = sInSeq;
            byte[] line = new byte[48];
            while (n + 3 <= 96) {
                int ln = 0;
                while ((b = f.read()) >= 0 && b != '\n' && ln < 47) line[ln++] = (byte) b;
                if (ln == 0) break;
                int i = 0;
                long idx = 0;
                while (i < ln && line[i] >= '0' && line[i] <= '9') { idx = idx * 10 + (line[i] - '0'); i++; }
                while (i < ln && (line[i] == ' ' || line[i] == '\t')) i++;
                if (i >= ln) continue;  // torn/garbage line (seq guards the usual case)
                char k = (char) line[i++];
                if (k != 'D' && k != 'M' && k != 'U' && k != 'K') continue;
                while (i < ln && (line[i] == ' ' || line[i] == '\t')) i++;
                int x = 0;
                while (i < ln && line[i] >= '0' && line[i] <= '9') { x = x * 10 + (line[i] - '0'); i++; }
                while (i < ln && (line[i] == ' ' || line[i] == '\t')) i++;
                int y = 0;
                while (i < ln && line[i] >= '0' && line[i] <= '9') { y = y * 10 + (line[i] - '0'); i++; }
                if (idx <= sInSeq) continue;  // already consumed on an earlier poll
                if (idx > maxIdx) maxIdx = idx;
                vals[n++] = k == 'D' ? 0 : k == 'M' ? 1 : k == 'U' ? 2 : 3;  // 3 = key (x=sym, y=flags)
                vals[n++] = x;
                vals[n++] = y;
            }
            try { f.close(); } catch (Throwable ignored) { }
            sInSeq = maxIdx;  // the max we actually read, so a torn tail re-reads cleanly
            return java.util.Arrays.copyOf(vals, n);
        } catch (Throwable t) {
            return new int[0];
        }
    }

    // NOD-26 self-check: the cursor reader keeps every event the compositor
    // published, even when several land between polls, and never replays one.
    // Runs standalone (no device Screen): dalvikvm ... Launcher inputtest.
    static void writeInput(String base, long total, String body) throws Exception {
        java.io.FileOutputStream fi = new java.io.FileOutputStream(base + ".input");
        fi.write(body.getBytes("US-ASCII"));
        fi.close();
        java.io.FileOutputStream fs = new java.io.FileOutputStream(base + ".input.seq");
        fs.write((total + "\n").getBytes("US-ASCII"));
        fs.close();
    }

    static void inputTest() throws Exception {
        String data = System.getenv("ANDROID_DATA");
        String base = (data != null ? data : ".") + "/q20-inputtest";
        sInSeq = -1;
        // A down/move/up burst the old per-poll overwrite collapsed to just the up.
        writeInput(base, 3, "1 D 10 20\n2 M 11 21\n3 U 12 22\n");
        int[] a = q20PollInput(base);
        check("input burst keeps D,M,U", a.length == 9
                && a[0] == 0 && a[1] == 10 && a[3] == 1 && a[6] == 2 && a[7] == 12);
        // Same seq: nothing replayed.
        check("input no replay", q20PollInput(base).length == 0);
        // Ring still shows old events; the cursor emits only the new one.
        writeInput(base, 4, "2 M 11 21\n3 U 12 22\n4 D 30 40\n");
        int[] b = q20PollInput(base);
        check("input cursor emits only new", b.length == 3 && b[0] == 0 && b[1] == 30 && b[2] == 40);
        // A torn last line (seq already bumped): the good line lands, the tail is skipped.
        writeInput(base, 6, "5 M 31 41\n6 ");
        int[] c = q20PollInput(base);
        check("input torn tail skipped", c.length == 3 && c[0] == 1 && c[1] == 31 && c[2] == 41);
        // A forwarded keyboard line surfaces as a key event: kind 3, sym, flags.
        writeInput(base, 7, "7 K 104 1\n");
        int[] d = q20PollInput(base);
        check("input key line -> kind 3", d.length == 3 && d[0] == 3 && d[1] == 104 && d[2] == 1);
        new java.io.File(base + ".input").delete();
        new java.io.File(base + ".input.seq").delete();
        sInSeq = -1;
    }

    // NOD-35 scroll perf: seed 50 notes, fling the list, and run a bounded
    // draw loop so perf() prints the per-frame layout/draw breakdown. No
    // compositor (Q20_DRAW_RAW unset): the cost measured is layout + draw.
    static void scroll(String apk, String cls) throws Exception {
        activity(apk, cls);
        Activity act = sStack.peek();
        int n = 50;
        ContentResolver cr = act.getContentResolver();
        Uri dir = Uri.parse("content://" + sAppAuthority + "/notes");
        for (int i = 0; i < n; i++) {
            ContentValues v = new ContentValues();
            v.put("title", "note " + i);
            v.put("note", "body of note number " + i);
            cr.insert(dir, v);
        }
        ListView lv = firstListView(sDecor);
        if (lv == null) throw new IllegalStateException("no ListView to scroll");
        android.widget.ListAdapter ad = lv.getAdapter();
        while (ad instanceof android.widget.WrapperListAdapter) ad = ((android.widget.WrapperListAdapter) ad).getWrappedAdapter();
        if (ad instanceof android.widget.CursorAdapter) {
            Cursor cur = ((android.widget.CursorAdapter) ad).getCursor();
            if (cur != null) cur.requery();
        }
        layoutPass();
        check("list seeded " + lv.getAdapter().getCount() + " rows", lv.getAdapter().getCount() >= n);

        // One throwaway frame to warm the glyph cache and surface, then fling.
        draw();
        java.util.Arrays.fill(sSum, 0);
        java.util.Arrays.fill(sMax, 0);
        sPerfN = 0;
        sFlingFrames = 0;
        flingUp(lv);
        measureFrames(2000);
        check("fling drew " + sFlingFrames + " frames", sFlingFrames > 0);
    }

    // A quick upward fling: a down, a few fast upward moves (timestamped so the
    // VelocityTracker builds velocity), then an up. ListView flings from there.
    static void flingUp(View lv) {
        int x = SCREEN_PX / 2;
        long t = SystemClock.uptimeMillis();
        touch(t, t, MotionEvent.ACTION_DOWN, x, 620);
        for (int i = 1; i <= 6; i++) touch(t, t + i * 8, MotionEvent.ACTION_MOVE, x, 620 - i * 95);
        touch(t, t + 56, MotionEvent.ACTION_UP, x, 50);
    }

    // Tick for ms milliseconds: each tick lays out and draws if the fling left
    // the tree dirty, and perf() prints every 30 frames. A bounded Looper.loop
    // like taps(): the fling's own posted animation callbacks run between ticks.
    static int sFlingFrames;
    static void measureFrames(final int ms) {
        final long end = SystemClock.uptimeMillis() + ms;
        final RuntimeException stop = new RuntimeException("scroll done");
        sHandler.post(new Runnable() {
            public void run() {
                boolean drew = false;
                try {
                    drew = tick();
                    if (drew) sFlingFrames++;
                } catch (Throwable t) {
                    System.out.println("facade: scroll tick threw " + rootCause(t));
                }
                // Same pacing as live(): animating reposts now (the vsync post
                // paces it), idle backs off to 16 ms.
                if (SystemClock.uptimeMillis() < end) sHandler.postDelayed(this, drew ? 0 : 16);
                else throw stop;
            }
        });
        try {
            Looper.loop();
        } catch (RuntimeException e) {
            if (e != stop) throw e;
        }
    }

    static ListView firstListView(View v) {
        if (v instanceof ListView) return (ListView) v;
        if (v instanceof ViewGroup) {
            ViewGroup g = (ViewGroup) v;
            for (int i = 0; i < g.getChildCount(); i++) {
                ListView l = firstListView(g.getChildAt(i));
                if (l != null) return l;
            }
        }
        return null;
    }

    // A9: the resident loop, ViewRootImpl's job in miniature. A main looper
    // tick polls the compositor's input file and turns taps into clicks, then
    // lays out when a view asked and draws when anything is dirty. Between
    // ticks the looper runs the app's own posted work: clicks, focus, animator
    // frames (Choreographer on Handler timing, device/build.prop).
    static void live() {
        System.out.println("facade: live loop - touch the app");
        sHandler.post(new Runnable() {
            public void run() {
                boolean drew = false;
                try {
                    drew = tick();
                } catch (Throwable t) {
                    System.out.println("facade: tick threw " + rootCause(t));
                    t.printStackTrace(System.out);
                }
                // While animating, repost now: the vsync-blocked post already
                // paces the frame (50 notes fling at ~58 fps instead of 28 with
                // a 16 ms delay stacked on top, NOD-35). Idle, back off to 16 ms
                // so we don't wake the app for nothing. ponytail: stage W (event
                // driven frames) removes the poll entirely.
                sHandler.postDelayed(this, drew ? 0 : 16);
            }
        });
        Looper.loop();
    }

    // Touches go in as real MotionEvents (A9: the stock MotionEvent and
    // VelocityTracker natives), so pressed state, ripples, long press and
    // swipes are the framework's own; clicks arrive through View.post.
    static long sDownTime;
    static boolean sTouching;
    static boolean sLogNextFrame;
    // Returns whether it drew a frame, so the caller can repost immediately
    // while animating (the vsync-blocked post paces it) and back off to 16 ms
    // when idle instead of waking the app for nothing.
    static boolean tick() throws Exception {
        int[] ev = q20PollInput();
        for (int i = 0; i + 2 < ev.length; i += 3) {
            int kind = ev[i], x = ev[i + 1], y = ev[i + 2];
            if (kind == 3) { liveKey(x, y); continue; }  // x=sym, y=flags
            long now = SystemClock.uptimeMillis();
            // The cursor transport keeps every event now, but if a down ever
            // slides out of the compositor's 32-event ring we would see a
            // move/up with no down; Views drop those, so synthesize the down.
            if (kind != 0 && !sTouching) {
                sDownTime = now;
                touch(sDownTime, now, MotionEvent.ACTION_DOWN, x, y);
            }
            if (kind == 0) sDownTime = now;
            sTouching = kind != 2;
            touch(sDownTime, now, kind == 0 ? MotionEvent.ACTION_DOWN
                    : kind == 1 ? MotionEvent.ACTION_MOVE : MotionEvent.ACTION_UP, x, y);
            if (kind != 1) System.out.println("facade: touch " + (kind == 0 ? "down" : "up") + " " + x + "," + y);
            sLogNextFrame |= kind == 2;
        }
        long t0 = SystemClock.uptimeMillis();
        boolean laidOut = sDecor.isLayoutRequested();
        if (laidOut) layoutPass();
        if (laidOut || sDecor.isDirty()) {
            sMs[0] = (int) (SystemClock.uptimeMillis() - t0);
            draw();
            perf();
            if (sLogNextFrame) System.out.println("facade: drew frame " + sFrames + " " + times(sMs));
            sLogNextFrame = false;
            return true;
        }
        return false;
    }

    // Perf: layout, lock, draw and post of each live frame in ms (post
    // includes the Q20_DRAW_RAW frame write), summed into avg/max every 30
    // frames. span is the wall time those 30 frames took, so during a steady
    // animation fps = 29000 / span.
    static final String[] PERF = { "layout", "lock", "draw", "post" };
    static final int[] sMs = new int[4], sSum = new int[4], sMax = new int[4];
    static int sPerfN;
    static long sPerfStart;
    static String times(int[] ms) {
        StringBuilder b = new StringBuilder();
        for (int i = 0; i < ms.length; i++) b.append(PERF[i]).append('=').append(ms[i]).append(' ');
        return b.append("ms").toString();
    }
    static void perf() {
        long now = SystemClock.uptimeMillis();
        if (sPerfN == 0) sPerfStart = now;
        for (int i = 0; i < sMs.length; i++) { sSum[i] += sMs[i]; sMax[i] = Math.max(sMax[i], sMs[i]); }
        if (++sPerfN < 30) return;
        StringBuilder b = new StringBuilder("facade: perf 30 frames span=" + (now - sPerfStart) + " avg/max");
        for (int i = 0; i < sMs.length; i++) b.append(' ').append(PERF[i]).append('=').append(sSum[i] / 30).append('/').append(sMax[i]);
        System.out.println(b.append(" ms"));
        sPerfN = 0;
        java.util.Arrays.fill(sSum, 0);
        java.util.Arrays.fill(sMax, 0);
    }

    static void touch(long downTime, long eventTime, int action, float x, float y) {
        MotionEvent me = MotionEvent.obtain(downTime, eventTime, action, x, y, 0);
        me.setSource(InputDevice.SOURCE_TOUCHSCREEN);
        sDecor.dispatchTouchEvent(me);
        me.recycle();
    }

    // A9 headless touch check: run the arguments in order on the main looper.
    // A view id is a tap through the real dispatch path (MotionEvents into
    // the decor, the click posted back to the looper); id=text checks that
    // TextView at that point. Taps are 800 ms apart, past
    // config_longAnimTime, so result animations settle in between.
    static void taps(String[] args) throws Exception {
        long at = 300;
        for (final String a : args) {
            final int eq = a.indexOf('=');
            sHandler.postDelayed(new Runnable() {
                public void run() {
                    if (sDecor.isLayoutRequested()) layoutPass();  // what the live tick does
                    try {
                        if (a.startsWith("@")) { menuItem(a.substring(1)); return; }
                        if (a.startsWith("type:")) { type(a.substring(5)); return; }
                        if (a.startsWith("keys:")) { keys(a.substring(5)); return; }
                        if (a.startsWith("key:")) { keyEvent(a.substring(4)); return; }
                        if (a.startsWith("long:")) { contextMenu(a.substring(5)); return; }
                    } catch (Exception e) { throw new RuntimeException(a, e); }
                    if (eq >= 0) {
                        View v = viewById(a.substring(0, eq));
                        CharSequence text = v instanceof TextView ? ((TextView) v).getText() : null;
                        check(a + " (got \"" + text + "\")", text != null && a.substring(eq + 1).contentEquals(text));
                        return;
                    }
                    View v = viewById(a);
                    int[] loc = new int[2];
                    v.getLocationInWindow(loc);
                    float x = loc[0] + v.getWidth() / 2f, y = loc[1] + v.getHeight() / 2f;
                    long t = SystemClock.uptimeMillis();
                    touch(t, t, MotionEvent.ACTION_DOWN, x, y);
                    touch(t, t + 60, MotionEvent.ACTION_UP, x, y);
                    System.out.println("facade: tapped " + a + " at " + (int) x + "," + (int) y);
                }
            }, at);
            if (eq < 0) at += 800;
        }
        // ponytail: the main looper may not quit, so a sentinel thrown from
        // a posted runnable ends this loop() after the last argument.
        final RuntimeException done = new RuntimeException("taps done");
        sHandler.postDelayed(new Runnable() {
            public void run() { throw done; }
        }, at + 300);
        try {
            Looper.loop();
        } catch (RuntimeException e) {
            if (e != done) throw e;
        }
        dump(sDecor, "", 0, 0);
    }

    // The first shown view with this id: layouts repeat an id and hide all
    // but one (the Calculator's numeric and operator = buttons).
    static View viewById(String name) {
        Resources res = sDecor.getResources();
        int id = res.getIdentifier(name, "id", sDecor.getContext().getPackageName());
        if (id == 0) id = res.getIdentifier(name, "id", "android");  // stock ids, e.g. text1
        View v = id != 0 ? shownById(sDecor, id) : null;
        if (v == null) throw new IllegalArgumentException("no shown view with id " + name);
        return v;
    }

    // Tap harness verbs (NOD-32). @<title>: the options-menu item, dispatched
    // the way the action bar would (onMenuItemSelected -> onOptionsItemSelected).
    static void menuItem(String label) throws Exception {
        final Activity top = sStack.peek();
        Object menu = make("com.android.internal.view.menu.MenuBuilder", top);
        // performItemAction routes app-handled items through this callback (to
        // onOptionsItemSelected) and falls back to an item's intent otherwise;
        // without a callback it returns false and nothing fires.
        Class<?> cbClass = Class.forName("com.android.internal.view.menu.MenuBuilder$Callback");
        Object cb = Proxy.newProxyInstance(cbClass.getClassLoader(), new Class<?>[] { cbClass },
                new InvocationHandler() {
                    public Object invoke(Object p, Method m, Object[] a) throws Throwable {
                        if (m.getName().equals("onMenuItemSelected")) {
                            return top.onMenuItemSelected(Window.FEATURE_OPTIONS_PANEL, (MenuItem) a[1]);
                        }
                        return null;  // onMenuModeChange: void
                    }
                });
        call(menu, "setCallback", cb);
        Menu mb = (Menu) menu;
        top.onCreateOptionsMenu(mb);
        top.onPrepareOptionsMenu(mb);
        for (int i = 0; i < mb.size(); i++) {
            MenuItem item = mb.getItem(i);
            CharSequence t = item.getTitle();
            if (t != null && label.contentEquals(t)) {
                boolean ok = (Boolean) call(menu, "performItemAction", item, 0);
                System.out.println("facade: menu \"" + label + "\" selected=" + ok);
                return;
            }
        }
        throw new IllegalArgumentException("no menu item \"" + label + "\"");
    }

    // type:<text> -> the first EditText under the current decor (NoteEditor's note).
    static void type(String str) {
        EditText et = firstEditText(sDecor);
        if (et == null) throw new IllegalArgumentException("no EditText to type into");
        et.setText(str);
        System.out.println("facade: typed \"" + str + "\" into " + et.getClass().getSimpleName());
    }

    static EditText firstEditText(View v) {
        if (v instanceof EditText) return (EditText) v;
        if (v instanceof ViewGroup) {
            ViewGroup g = (ViewGroup) v;
            for (int i = 0; i < g.getChildCount(); i++) {
                EditText e = firstEditText(g.getChildAt(i));
                if (e != null) return e;
            }
        }
        return null;
    }

    // A key the compositor forwarded from the Q20 keyboard (NOD-33): sym is a
    // unicode codepoint for a printable key or a 0xf0xx QNX KEYCODE for a special
    // one, flags carries KEY_DOWN (0x1). Printables type their char; the mapped
    // specials dispatch a KeyEvent; Escape/Back pops the stack.
    static void liveKey(int sym, int flags) throws Exception {
        if ((flags & 0x1) == 0) return;  // act on the press, not the release
        if (sym >= 0x20 && sym < 0x7f) { keys(String.valueOf((char) sym)); return; }
        int code = symToKeyCode(sym);
        if (code == -1) { back(); return; }
        if (code != 0) {
            if (code == KeyEvent.KEYCODE_DEL || code == KeyEvent.KEYCODE_ENTER) {
                EditText et = firstEditText(sDecor);
                if (et != null) et.requestFocus();
            }
            long t = SystemClock.uptimeMillis();
            sDecor.dispatchKeyEvent(new KeyEvent(t, t, KeyEvent.ACTION_DOWN, code, 0));
            sDecor.dispatchKeyEvent(new KeyEvent(t, t, KeyEvent.ACTION_UP, code, 0));
        }
        System.out.println("facade: live key sym=0x" + Integer.toHexString(sym) + " code=" + code);
    }

    // QNX key syms (sys/keycodes.h: KEYCODE_PC_KEYS = 0xf000) to Android key
    // codes. -1 means pop the stack (Escape; the Q20 Back button's own sym is
    // logged by the compositor so this can be tuned on a real device).
    static int symToKeyCode(int sym) {
        switch (sym) {
            case 0x08: case 0xf008: return KeyEvent.KEYCODE_DEL;
            case 0x0a: case 0x0d: case 0xf00d: return KeyEvent.KEYCODE_ENTER;
            case 0xf051: return KeyEvent.KEYCODE_DPAD_LEFT;
            case 0xf053: return KeyEvent.KEYCODE_DPAD_RIGHT;
            case 0xf052: return KeyEvent.KEYCODE_DPAD_UP;
            case 0xf054: return KeyEvent.KEYCODE_DPAD_DOWN;
            case 0xf067: return KeyEvent.KEYCODE_MENU;
            case 0x1b: case 0xf01b: return -1;  // Escape -> Back
            default: return 0;
        }
    }

    // keys:<text> -> type through real key input, not setText. One ACTION_MULTIPLE
    // KeyEvent carries the string to the focused EditText's KeyListener, the same
    // path the live hardware keyboard reaches (NOD-33). This is what the Q20's
    // physical keys drive once the compositor forwards them.
    static void keys(String str) {
        EditText et = firstEditText(sDecor);
        if (et != null) et.requestFocus();
        long t = SystemClock.uptimeMillis();
        boolean ok = sDecor.dispatchKeyEvent(new KeyEvent(t, str, KeyCharacterMap.VIRTUAL_KEYBOARD, 0));
        System.out.println("facade: keys \"" + str + "\" handled=" + ok);
    }

    // long:<rowId>:<item> -> long-press a list row and pick a context-menu item.
    // The real path shows an AlertDialog (MenuDialogHelper); the facade builds the
    // same ContextMenuBuilder, attaches the row's AdapterContextMenuInfo (its id
    // is what onContextItemSelected reads), and dispatches directly.
    static void contextMenu(String spec) throws Exception {
        int c = spec.indexOf(':');
        if (c < 0) throw new IllegalArgumentException("long:<rowId>:<item>");
        View row = viewById(spec.substring(0, c));
        String title = spec.substring(c + 1);
        ListView lv = null;
        for (android.view.ViewParent par = row.getParent(); par instanceof View; par = par.getParent()) {
            if (par instanceof ListView) { lv = (ListView) par; break; }
        }
        if (lv == null) throw new IllegalArgumentException("no ListView over " + spec.substring(0, c));
        int pos = lv.getPositionForView(row);
        long id = lv.getItemIdAtPosition(pos);
        Activity top = sStack.peek();
        Object menu = make("com.android.internal.view.menu.ContextMenuBuilder", top);
        Object info = make("android.widget.AdapterView$AdapterContextMenuInfo", row, pos, id);
        call(menu, "setCurrentMenuInfo", info);  // added items carry this menuInfo
        top.onCreateContextMenu((android.view.ContextMenu) menu, row,
                (android.view.ContextMenu.ContextMenuInfo) info);
        Menu mb = (Menu) menu;
        for (int i = 0; i < mb.size(); i++) {
            MenuItem item = mb.getItem(i);
            CharSequence t = item.getTitle();
            if (t != null && title.contentEquals(t)) {
                boolean ok = top.onContextItemSelected(item);
                // A context action changes the provider in place (Delete); with
                // no stop/restart to requery the managed cursor, refresh it here.
                android.widget.ListAdapter ad = lv.getAdapter();
                while (ad instanceof android.widget.WrapperListAdapter) {
                    ad = ((android.widget.WrapperListAdapter) ad).getWrappedAdapter();
                }
                if (ad instanceof android.widget.CursorAdapter) {
                    Cursor cur = ((android.widget.CursorAdapter) ad).getCursor();
                    if (cur != null) cur.requery();
                }
                layoutPass();
                System.out.println("facade: context \"" + title + "\" pos=" + pos + " id=" + id + " handled=" + ok);
                return;
            }
        }
        throw new IllegalArgumentException("no context item \"" + title + "\"");
    }

    // key:<NAME> -> a single hardware key, down then up. BACK pops the stack
    // (the Q20 has no software bar); the rest dispatch into the focused view.
    static void keyEvent(String name) throws Exception {
        if (name.equals("BACK")) { back(); return; }
        int code = keyCode(name);
        if (code == 0) throw new IllegalArgumentException("unhandled key " + name);
        if ("ENTER DEL".indexOf(name) >= 0) { EditText et = firstEditText(sDecor); if (et != null) et.requestFocus(); }
        long t = SystemClock.uptimeMillis();
        sDecor.dispatchKeyEvent(new KeyEvent(t, t, KeyEvent.ACTION_DOWN, code, 0));
        sDecor.dispatchKeyEvent(new KeyEvent(t, t, KeyEvent.ACTION_UP, code, 0));
        System.out.println("facade: key " + name);
    }

    // The Q20 keys the ports use. Printable characters come through keys:/the
    // compositor's unicode sym, so only the named non-printables map here.
    static int keyCode(String n) {
        if (n.equals("ENTER")) return KeyEvent.KEYCODE_ENTER;
        if (n.equals("DEL")) return KeyEvent.KEYCODE_DEL;  // Backspace
        if (n.equals("MENU")) return KeyEvent.KEYCODE_MENU;
        if (n.equals("UP")) return KeyEvent.KEYCODE_DPAD_UP;
        if (n.equals("DOWN")) return KeyEvent.KEYCODE_DPAD_DOWN;
        if (n.equals("LEFT")) return KeyEvent.KEYCODE_DPAD_LEFT;
        if (n.equals("RIGHT")) return KeyEvent.KEYCODE_DPAD_RIGHT;
        if (n.equals("CENTER")) return KeyEvent.KEYCODE_DPAD_CENTER;
        return 0;
    }

    // Visibility checked on the way down: View.isShown() wants a ViewRootImpl
    // parent above the decor and answers false here.
    static View shownById(View v, int id) {
        if (v.getVisibility() != View.VISIBLE) return null;
        if (v.getId() == id) return v;
        if (v instanceof ViewGroup) {
            ViewGroup g = (ViewGroup) v;
            for (int i = 0; i < g.getChildCount(); i++) {
                View hit = shownById(g.getChildAt(i), id);
                if (hit != null) return hit;
            }
        }
        return null;
    }

    static int sFrames;
    static Surface sSurface;
    static void draw() throws Exception {
        if (sDecor == null) throw new IllegalStateException("nothing laid out to draw");
        // Surface() is public in the framework but hidden from android-23.jar,
        // so it comes through the same reflection door as everything else here.
        long t0 = SystemClock.uptimeMillis();
        if (sSurface == null) {  // one Surface (and its Canvas) for every frame
            sSurface = (Surface) make("android.view.Surface");
            set(sSurface, "mNativeObject", 1L);
        }
        Surface s = sSurface;
        Canvas c = s.lockCanvas(null);
        boolean first = sFrames++ == 0;
        if (first) {
            check("canvas " + c.getWidth() + "x" + c.getHeight(), c.getWidth() > 0 && c.getHeight() > 0);
            themeColor("colorButtonNormal", android.R.attr.colorButtonNormal);
            themeColor("colorControlHighlight", android.R.attr.colorControlHighlight);
            themeColor("textColorPrimary", android.R.attr.textColorPrimary);
        }
        long t1 = SystemClock.uptimeMillis();
        sDecor.draw(c);
        long t2 = SystemClock.uptimeMillis();
        s.unlockCanvasAndPost(c);
        sMs[1] = (int) (t1 - t0);
        sMs[2] = (int) (t2 - t1);
        sMs[3] = (int) (SystemClock.uptimeMillis() - t2);
        if (first) check("draw pass completed", true);
    }

    // Which theme attribute the button background resolves through: the draw
    // trace shows the fill arriving as pure white, which no Material palette
    // contains, so the question is resources, not rasterizing.
    static void themeColor(String name, int attr) {
        TypedValue tv = new TypedValue();
        boolean got = sDecor.getContext().getTheme().resolveAttribute(attr, tv, true);
        System.out.println("facade: theme " + name + " resolved=" + got + " type=" + tv.type
                + " data=#" + Integer.toHexString(tv.data) + " res=0x" + Integer.toHexString(tv.resourceId));
    }

    static Configuration configuration(int dpi) throws Exception {
        Configuration c = new Configuration();
        c.setToDefaults();
        c.locale = Locale.getDefault();
        c.setLayoutDirection(c.locale);
        c.densityDpi = dpi;
        c.screenWidthDp = c.screenHeightDp = c.smallestScreenWidthDp = SCREEN_PX * 160 / dpi;
        // Square: WindowManager says portrait (w <= h). Calibration knob
        // q20.facade.orientation (device/build.prop): phone portrait layouts
        // assume ~640 dp of height, and their landscape ones fit 360x360 dp.
        Object orientation = call(Class.forName("android.os.SystemProperties"), "get",
                "q20.facade.orientation", "portrait");
        c.orientation = "landscape".equals(orientation)
                ? Configuration.ORIENTATION_LANDSCAPE : Configuration.ORIENTATION_PORTRAIT;
        c.screenLayout = Configuration.SCREENLAYOUT_SIZE_NORMAL | Configuration.SCREENLAYOUT_LONG_NO
                | Configuration.SCREENLAYOUT_LAYOUTDIR_LTR;
        c.touchscreen = Configuration.TOUCHSCREEN_FINGER;
        c.keyboard = Configuration.KEYBOARD_QWERTY;
        c.keyboardHidden = Configuration.KEYBOARDHIDDEN_NO;
        c.hardKeyboardHidden = Configuration.HARDKEYBOARDHIDDEN_NO;
        c.navigation = Configuration.NAVIGATION_TRACKBALL;  // the Q20 trackpad
        c.navigationHidden = Configuration.NAVIGATIONHIDDEN_NO;
        c.uiMode = Configuration.UI_MODE_TYPE_NORMAL | Configuration.UI_MODE_NIGHT_NO;
        return c;
    }

    static int id(Activity act, String name) {
        return act.getResources().getIdentifier(name, "id", act.getPackageName());
    }

    static boolean inside(View v, View root) {
        int x = 0, y = 0;
        for (View p = v; p != root && p != null; p = (View) p.getParent()) {
            x += p.getLeft();
            y += p.getTop();
        }
        return x >= 0 && y >= 0 && x + v.getWidth() <= root.getWidth() && y + v.getHeight() <= root.getHeight();
    }

    static void dump(View v, String indent, int ox, int oy) {
        String id = "";
        if (v.getId() > 0) {
            try {
                id = " id=" + v.getResources().getResourceEntryName(v.getId());
            } catch (Resources.NotFoundException e) {
                id = " id=0x" + Integer.toHexString(v.getId());
            }
        }
        int x = ox + v.getLeft(), y = oy + v.getTop();
        System.out.println("facade: view " + indent + v.getClass().getSimpleName() + id + " " + x + "," + y
                + " " + v.getWidth() + "x" + v.getHeight()
                + (v.getVisibility() == View.GONE ? " gone" : "")
                + (v instanceof TextView ? " \"" + ((TextView) v).getText() + "\"" : ""));
        if (v instanceof ViewGroup) {
            ViewGroup g = (ViewGroup) v;
            for (int i = 0; i < g.getChildCount(); i++) dump(g.getChildAt(i), indent + "  ", x, y);
        }
    }

    // ---- fake system services ----

    static final Map<String, IBinder> SERVICES = new HashMap<String, IBinder>();

    /**
     * No system_server: window, display and activity are local Proxy objects
     * behind a Binder (IFoo.Stub.asInterface finds them via queryLocalInterface).
     * Every call is logged: the log is the list of system service methods an
     * app really reaches, the shopping list for our own services.
     */
    static void installServices(int dpi) throws Exception {
        Map<String, Object> window = new HashMap<String, Object>();
        window.put("getCurrentAnimatorScale", 1f);
        SERVICES.put("window", serve("window", "android.view.IWindowManager", window));
        Map<String, Object> display = new HashMap<String, Object>();
        display.put("getDisplayInfo", displayInfo(dpi));
        display.put("getDisplayIds", new int[] { 0 });
        SERVICES.put("display", serve("display", "android.hardware.display.IDisplayManager", display));
        SERVICES.put("activity", serve("activity", "android.app.IActivityManager", new HashMap<String, Object>()));
        // A9: every EditText's Editor requires a PackageManager, which
        // ContextImpl only builds when this service answers.
        SERVICES.put("package", packageService());
        // EditText attach and focus: spell checking (off) and the input method.
        SERVICES.put("textservices", serve("textservices",
                "com.android.internal.textservice.ITextServicesManager", new HashMap<String, Object>()));
        SERVICES.put("input_method", serve("input_method",
                "com.android.internal.view.IInputMethodManager", new HashMap<String, Object>()));
        // Answers state 0 (disabled) once; when missing, AccessibilityManager
        // asks again on every event (hundreds of lookups per tap).
        SERVICES.put("accessibility", serve("accessibility",
                "android.view.accessibility.IAccessibilityManager", new HashMap<String, Object>()));

        // Cursor change notification (setNotificationUri, notifyChange).
        SERVICES.put("content", serve("content", "android.content.IContentService", new HashMap<String, Object>()));
        // NotesList.onPrepareOptionsMenu asks the clipboard whether Paste is live;
        // context Copy writes to it and Paste reads it, so it holds real state.
        SERVICES.put("clipboard", clipboardService());
        // NOD-33: a text field's TextKeyListener loads a KeyCharacterMap through
        // InputManager. Serve one virtual-keyboard device whose KCM is a minimal
        // FULL map (ACTION_MULTIPLE inserts from getCharacters(), so no per-key
        // table is needed); the real one arrives once the compositor forwards keys.
        Map<String, Object> input = new HashMap<String, Object>();
        input.put("getInputDeviceIds", new int[] { KeyCharacterMap.VIRTUAL_KEYBOARD });
        input.put("getInputDevice", virtualKeyboard());
        SERVICES.put("input", serve("input", "android.hardware.input.IInputManager", input));
        // Loading a menu item's icon badges it for the user profile; answer no
        // profiles so the badge step is skipped (addIntentOptions, context menus).
        Map<String, Object> user = new HashMap<String, Object>();
        user.put("getProfiles", new ArrayList<Object>());
        SERVICES.put("user", serve("user", "android.os.IUserManager", user));

        // Unknown names answer null, as a missing service would.
        Class<?> sm = Class.forName("android.os.IServiceManager");
        Object manager = Proxy.newProxyInstance(sm.getClassLoader(), new Class<?>[] { sm },
                new InvocationHandler() {
                    public Object invoke(Object proxy, Method m, Object[] args) {
                        if (m.getName().equals("getService") || m.getName().equals("checkService")) {
                            IBinder b = SERVICES.get(args[0]);
                            System.out.println("facade: sm " + (b != null ? "hit " : "miss ") + args[0]);
                            return b;
                        }
                        return zero(m.getReturnType());
                    }
                });
        setStatic(Class.forName("android.os.ServiceManager"), "sServiceManager", manager);
    }

    // A fake VIRTUAL_KEYBOARD InputDevice carrying a minimal FULL KeyCharacterMap.
    // nativeReadFromParcel wants [deviceId, type, numKeys]; a FULL type with zero
    // keys is enough for TextKeyListener to pick the QWERTY listener, and
    // ACTION_MULTIPLE inserts straight from the event's characters.
    static Object virtualKeyboard() throws Exception {
        Parcel p = Parcel.obtain();
        p.writeInt(KeyCharacterMap.VIRTUAL_KEYBOARD);  // deviceId (read first)
        p.writeInt(KeyCharacterMap.FULL);              // KeyCharacterMap type
        p.writeInt(0);                                 // no per-key entries
        p.setDataPosition(0);
        KeyCharacterMap kcm = KeyCharacterMap.CREATOR.createFromParcel(p);
        p.recycle();
        // The 14-arg private ctor: id, generation, controllerNumber, name,
        // vendorId, productId, descriptor, isExternal, sources, keyboardType,
        // keyCharacterMap, hasVibrator, hasMicrophone, hasButtonUnderPad.
        return make("android.view.InputDevice", KeyCharacterMap.VIRTUAL_KEYBOARD, 0, 0, "q20-virtual",
                0, 0, "virtual", false, InputDevice.SOURCE_KEYBOARD, InputDevice.KEYBOARD_TYPE_ALPHABETIC,
                kcm, false, false, false);
    }

    // The package manager answers queryIntentActivityOptions (NoteEditor's
    // addIntentOptions builds the "Note title:" alternative from it); everything
    // else is a logged no-op. Resolution reuses the same filter match as
    // resolveActivity, returning a ResolveInfo per matching activity (MenuBuilder
    // drops the caller itself).
    static IBinder packageService() throws Exception {
        final String iface = "android.content.pm.IPackageManager";
        final Binder binder = new Binder();
        Object proxy = Proxy.newProxyInstance(Class.forName(iface).getClassLoader(),
                new Class<?>[] { Class.forName(iface) }, new InvocationHandler() {
                    public Object invoke(Object p, Method m, Object[] args) throws Throwable {
                        String n = m.getName();
                        if (n.equals("asBinder")) return binder;
                        if (m.getDeclaringClass() == Object.class) {
                            if (n.equals("equals")) return p == args[0];
                            if (n.equals("hashCode")) return System.identityHashCode(p);
                            return "fake package";
                        }
                        if (n.equals("queryIntentActivityOptions")) return resolveInfos((Intent) args[3]);
                        System.out.println("facade: svc package." + n);
                        return zero(m.getReturnType());
                    }
                });
        binder.attachInterface((IInterface) proxy, iface);
        return binder;
    }

    static List<ResolveInfo> resolveInfos(Intent intent) throws Exception {
        ArrayList<ResolveInfo> out = new ArrayList<ResolveInfo>();
        ContentResolver cr = sApp.getContentResolver();
        for (Object a : (List<?>) get(sPkg, "activities")) {
            for (Object f : (List<?>) get(a, "intents")) {
                if (((IntentFilter) f).match(cr, intent, true, "facade") >= 0) {
                    ResolveInfo ri = new ResolveInfo();
                    ri.activityInfo = (ActivityInfo) get(a, "info");
                    ri.filter = (IntentFilter) f;
                    out.add(ri);
                    break;
                }
            }
        }
        return out;
    }

    // A stateful clipboard: context Copy sets a ClipData, Paste and the Paste
    // menu item's enabled state read it back. The generic serve() can only
    // answer fixed values, so this one holds the clip.
    static ClipData sClip;
    static IBinder clipboardService() throws Exception {
        final String iface = "android.content.IClipboard";
        final Binder binder = new Binder();
        Object proxy = Proxy.newProxyInstance(Class.forName(iface).getClassLoader(),
                new Class<?>[] { Class.forName(iface) }, new InvocationHandler() {
                    public Object invoke(Object p, Method m, Object[] args) {
                        String n = m.getName();
                        if (n.equals("asBinder")) return binder;
                        if (m.getDeclaringClass() == Object.class) {
                            if (n.equals("equals")) return p == args[0];
                            if (n.equals("hashCode")) return System.identityHashCode(p);
                            return "fake clipboard";
                        }
                        if (n.equals("setPrimaryClip")) { sClip = (ClipData) args[0]; return null; }
                        if (n.equals("getPrimaryClip")) return sClip;
                        if (n.equals("hasPrimaryClip") || n.equals("hasClipboardText")) return sClip != null;
                        if (n.equals("getPrimaryClipDescription")) return sClip != null ? sClip.getDescription() : null;
                        return zero(m.getReturnType());
                    }
                });
        binder.attachInterface((IInterface) proxy, iface);
        return binder;
    }

    static IBinder serve(final String name, String iface, final Map<String, Object> answers) throws Exception {
        Class<?> c = Class.forName(iface);
        final Binder binder = new Binder();
        Object proxy = Proxy.newProxyInstance(c.getClassLoader(), new Class<?>[] { c },
                new InvocationHandler() {
                    public Object invoke(Object p, Method m, Object[] args) {
                        String n = m.getName();
                        if (n.equals("asBinder")) return binder;
                        if (m.getDeclaringClass() == Object.class) {
                            if (n.equals("equals")) return p == args[0];
                            if (n.equals("hashCode")) return System.identityHashCode(p);
                            return "fake " + name;
                        }
                        System.out.println("facade: svc " + name + "." + n);
                        return answers.containsKey(n) ? answers.get(n) : zero(m.getReturnType());
                    }
                });
        binder.attachInterface((IInterface) proxy, iface);
        return binder;
    }

    static Object displayInfo(int dpi) throws Exception {
        Object di = make("android.view.DisplayInfo");
        for (String f : new String[] { "appWidth", "appHeight", "smallestNominalAppWidth",
                "smallestNominalAppHeight", "largestNominalAppWidth", "largestNominalAppHeight",
                "logicalWidth", "logicalHeight" }) {
            set(di, f, SCREEN_PX);
        }
        Class<?> mode = Class.forName("android.view.Display$Mode");
        Object modes = Array.newInstance(mode, 1);
        Array.set(modes, 0, mode.getConstructor(int.class, int.class, int.class, float.class)
                .newInstance(1, SCREEN_PX, SCREEN_PX, 60f));
        set(di, "supportedModes", modes);
        set(di, "modeId", 1);
        set(di, "defaultModeId", 1);
        Class<?> transform = Class.forName("android.view.Display$ColorTransform");
        Object transforms = Array.newInstance(transform, 1);
        Array.set(transforms, 0, transform.getConstructor(int.class, int.class).newInstance(1, 0));
        set(di, "supportedColorTransforms", transforms);
        set(di, "colorTransformId", 1);
        set(di, "defaultColorTransformId", 1);
        set(di, "logicalDensityDpi", dpi);
        set(di, "physicalXDpi", (float) dpi);
        set(di, "physicalYDpi", (float) dpi);
        set(di, "type", 1);   // Display.TYPE_BUILT_IN
        set(di, "state", 2);  // Display.STATE_ON
        set(di, "name", "Built-in Screen");
        return di;
    }

    static Object zero(Class<?> t) {
        if (t == boolean.class) return false;
        if (t == int.class) return 0;
        if (t == long.class) return 0L;
        if (t == float.class) return 0f;
        if (t == double.class) return 0d;
        if (t == short.class) return (short) 0;
        if (t == byte.class) return (byte) 0;
        if (t == char.class) return (char) 0;
        return null;
    }

    // ---- reflection on hidden framework members (no hidden API checks on 6.0) ----

    static Object make(String cls, Object... args) throws Exception {
        for (java.lang.reflect.Constructor<?> c : Class.forName(cls).getDeclaredConstructors()) {
            if (c.getParameterTypes().length == args.length) {
                c.setAccessible(true);
                return c.newInstance(args);
            }
        }
        throw new NoSuchMethodException(cls + ".<init>/" + args.length);
    }

    /** Calls a method by name and arity; target is an instance or, for statics, a Class. */
    static Object call(Object target, String name, Object... args) throws Exception {
        boolean isStatic = target instanceof Class;
        for (Class<?> c = isStatic ? (Class<?>) target : target.getClass(); c != null; c = c.getSuperclass()) {
            for (Method m : c.getDeclaredMethods()) {
                if (m.getName().equals(name) && m.getParameterTypes().length == args.length) {
                    m.setAccessible(true);
                    return m.invoke(isStatic ? null : target, args);
                }
            }
        }
        throw new NoSuchMethodException(target + "." + name + "/" + args.length);
    }

    static Field field(Class<?> c, String name) throws NoSuchFieldException {
        for (; c != null; c = c.getSuperclass()) {
            try {
                Field f = c.getDeclaredField(name);
                f.setAccessible(true);
                return f;
            } catch (NoSuchFieldException e) {
                // try the superclass
            }
        }
        throw new NoSuchFieldException(name);
    }

    static Object get(Object o, String name) throws Exception { return field(o.getClass(), name).get(o); }
    static void set(Object o, String name, Object v) throws Exception { field(o.getClass(), name).set(o, v); }
    static Object getStatic(Class<?> c, String name) throws Exception { return field(c, name).get(null); }
    static void setStatic(Class<?> c, String name, Object v) throws Exception { field(c, name).set(null, v); }

    static Throwable rootCause(Throwable t) {
        while (t.getCause() != null) t = t.getCause();
        return t;
    }

    static void check(String name, boolean ok) {
        total++;
        if (ok) passed++;
        System.out.println("facade check: " + (ok ? "PASS " : "FAIL ") + name);
    }
}
