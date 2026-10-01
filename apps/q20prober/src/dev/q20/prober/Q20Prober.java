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

    /** Headless entry: pure Java, no framework natives, no window. */
    public static void main(String[] args) {
        System.out.println("prober: headless main running");
        int sum = 0;
        for (int i = 1; i <= 10; i++) {
            sum += i;
        }
        System.out.println("prober: self test sum=" + sum + " (want 55)");
        System.out.println("prober: headless main done, ok=" + (sum == 55));
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
