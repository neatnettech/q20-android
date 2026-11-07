package dev.q20.facade;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;

/**
 * A minimal provider for the "settings" authority. Settings.System/Secure/Global
 * reads go through its call() (and fall back to query); with no real provider
 * they NPE on a null IContentProvider. QwertyKeyListener reaching through
 * TextKeyListener for the auto-caps/auto-text flags is the first caller (NOD-33).
 * Returning an empty Bundle makes every lookup miss, so callers take their
 * documented default.
 */
public class SettingsStub extends ContentProvider {
    @Override public boolean onCreate() { return true; }
    @Override public Bundle call(String method, String arg, Bundle extras) { return new Bundle(); }
    @Override public Cursor query(Uri u, String[] p, String s, String[] sa, String so) { return null; }
    @Override public String getType(Uri u) { return null; }
    @Override public Uri insert(Uri u, ContentValues v) { return null; }
    @Override public int delete(Uri u, String s, String[] sa) { return 0; }
    @Override public int update(Uri u, ContentValues v, String s, String[] sa) { return 0; }
}
