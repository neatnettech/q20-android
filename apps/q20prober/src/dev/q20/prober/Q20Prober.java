package dev.q20.prober;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.TextView;

/**
 * The Q20 Prober: one Activity that exercises text, layout, resources,
 * input, invalidation and lifecycle. Also carries a headless main() so the
 * same APK can run without a window while the platform is brought up.
 */
public class Q20Prober extends Activity {
    public static final String TAG = "Q20Prober";

    private int counter;
    private TextView counterText;

    /** Headless entry: framework self tests, no window needed. */
    public static void main(String[] args) {
        System.out.println("prober: headless main running");
        int passed = 0;
        passed += check("java arithmetic", sum(10) == 55);
        passed += check("regex Pattern.matches",
                java.util.regex.Pattern.matches("^a+b$", "aaab"));
        passed += check("regex replace",
                "x1x2x".replaceAll("[0-9]", "n").equals("xnxnx"));
        passed += check("SystemClock", clockTest());
        passed += check("Log", logTest());
        passed += check("ICU PluralRules", icuTest());
        passed += check("Bundle", bundleTest());
        System.out.println("prober: headless done, passed=" + passed + "/7");
    }

    static int sum(int n) {
        int s = 0;
        for (int i = 1; i <= n; i++) s += i;
        return s;
    }

    static boolean bundleTest() {
        try {
            android.os.Bundle b = new android.os.Bundle();
            b.putString("k", "v");
            b.putInt("n", 7);
            return "v".equals(b.getString("k")) && b.getInt("n") == 7;
        } catch (Throwable t) {
            System.out.println("prober: bundle exception " + t);
            return false;
        }
    }

    static boolean clockTest() {
        long a = android.os.SystemClock.uptimeMillis();
        long b = android.os.SystemClock.uptimeMillis();
        return b >= a && a > 0;
    }

    static boolean logTest() {
        android.util.Log.i(TAG, "prober log test");
        android.util.Log.d(TAG, "prober log test");
        return true;
    }

    static boolean icuTest() {
        // android.icu is hidden API: reach it by reflection.
        try {
            Class<?> c = Class.forName("android.icu.text.PluralRules");
            java.lang.reflect.Method m = c.getDeclaredMethod("forLocale", java.util.Locale.class);
            Object rules = m.invoke(null, java.util.Locale.ENGLISH);
            java.lang.reflect.Method s = c.getDeclaredMethod("select", double.class);
            String sel = (String) s.invoke(rules, 2.0);
            return rules != null && sel != null && sel.length() > 0;
        } catch (Throwable t) {
            Throwable cause = t;
            while (cause.getCause() != null) cause = cause.getCause();
            System.out.println("prober: icu exception " + cause);
            return false;
        }
    }

    static int check(String name, boolean ok) {
        System.out.println("prober check: " + (ok ? "PASS " : "FAIL ") + name);
        return ok ? 1 : 0;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i(TAG, "onCreate");
        setContentView(R.layout.main);
        counterText = (TextView) findViewById(R.id.counter_text);
        Button bump = (Button) findViewById(R.id.bump_button);
        bump.setOnClickListener(new android.view.View.OnClickListener() {
            @Override
            public void onClick(android.view.View v) {
                counter++;
                counterText.setText(getString(R.string.counter_fmt, counter));
                Log.i(TAG, "bumped to " + counter);
            }
        });
        counterText.setText(getString(R.string.counter_fmt, counter));
    }

    @Override
    protected void onStart() {
        super.onStart();
        Log.i(TAG, "onStart");
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.i(TAG, "onResume");
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.i(TAG, "onPause");
    }
}
