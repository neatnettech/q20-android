package dev.q20.facade;

import android.content.res.AssetManager;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.os.Binder;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.os.Process;
import android.os.SystemClock;
import android.os.Trace;

import org.xmlpull.v1.XmlPullParser;

import java.util.Locale;

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
 */
public final class Launcher {
    private static int passed;
    private static int total;

    public static void main(String[] args) {
        String mode = args.length > 0 ? args[0] : "props";
        String apk = args.length > 1 ? args[1] : null;
        System.out.println("facade: mode " + mode);
        try {
            if (mode.equals("props")) {
                props();
            } else if (mode.equals("res")) {
                res(apk);
            } else if (mode.equals("looper")) {
                looper();
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
