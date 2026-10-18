package dev.q20.facade;

import android.app.Activity;
import android.app.Application;
import android.app.Instrumentation;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.os.Binder;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import android.os.Process;
import android.os.SystemClock;
import android.os.Trace;
import android.text.BoringLayout;
import android.text.TextPaint;
import android.system.Os;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.PathInterpolator;
import android.widget.TextView;

import org.xmlpull.v1.XmlPullParser;

import java.io.File;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
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
        Object thread = make("android.app.ActivityThread");
        Object compat = getStatic(Class.forName("android.content.res.CompatibilityInfo"),
                "DEFAULT_COMPATIBILITY_INFO");
        Object loadedApk = make("android.app.LoadedApk", thread, ai, compat, null, false, false, false);
        Class<?> contextImpl = Class.forName("android.app.ContextImpl");
        Context appContext = (Context) call(contextImpl, "createAppContext", thread, loadedApk);
        Application app = Instrumentation.newApplication(Application.class, appContext);
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

        Context base = (Context) call(contextImpl, "createActivityContext", thread, loadedApk, 0, null);
        CharSequence title = info.labelRes != 0 ? base.getResources().getText(info.labelRes) : info.name;
        Instrumentation instr = new Instrumentation();
        Activity act = instr.newActivity(ClassLoader.getSystemClassLoader().loadClass(cls), base,
                new Binder(), app, new Intent(Intent.ACTION_MAIN).setClassName(ai.packageName, cls),
                info, title, null, null, null);
        call(base, "setOuterContext", act);
        // ponytail: DeviceDefault's action bar needs a PackageManager and bitmap
        // decoding; the APK's own theme (none here) comes back at A9.
        act.setTheme(android.R.style.Theme_Material_NoActionBar);
        instr.callActivityOnCreate(act, null);
        call(act, "performStart");
        instr.callActivityOnPostCreate(act, null);
        call(act, "performResume");
        check("lifecycle " + lifecycle.toString().trim(),
                lifecycle.toString().equals("created started resumed "));

        // Phase 4: the window at the Q20 screen size, no ViewRootImpl.
        View decor = act.getWindow().getDecorView();
        int spec = View.MeasureSpec.makeMeasureSpec(SCREEN_PX, View.MeasureSpec.EXACTLY);
        decor.measure(spec, spec);
        decor.layout(0, 0, SCREEN_PX, SCREEN_PX);
        dump(decor, "", 0, 0);
        check("decor " + decor.getWidth() + "x" + decor.getHeight(),
                decor.getWidth() == SCREEN_PX && decor.getHeight() == SCREEN_PX);
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

    static Configuration configuration(int dpi) {
        Configuration c = new Configuration();
        c.setToDefaults();
        c.locale = Locale.getDefault();
        c.setLayoutDirection(c.locale);
        c.densityDpi = dpi;
        c.screenWidthDp = c.screenHeightDp = c.smallestScreenWidthDp = SCREEN_PX * 160 / dpi;
        c.orientation = Configuration.ORIENTATION_PORTRAIT;  // square: w <= h, as WindowManager decides
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
