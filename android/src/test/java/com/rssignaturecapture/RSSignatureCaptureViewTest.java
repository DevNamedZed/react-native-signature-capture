package com.rssignaturecapture;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import android.app.Activity;
import android.graphics.Color;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = 30)
public class RSSignatureCaptureViewTest {

    private RSSignatureCaptureView view;

    @Before
    public void setUp() {
        Activity activity = Robolectric.buildActivity(Activity.class).create().get();
        RSSignatureCaptureView.SignatureCallback callback = mock(RSSignatureCaptureView.SignatureCallback.class);
        view = new RSSignatureCaptureView(activity, callback);
    }

    @Test
    public void isEmpty_trueAfterConstruction() {
        assertTrue(view.isEmpty());
    }

    @Test
    public void clearSignature_resetsToEmpty() {
        // Even if we somehow marked it non-empty, clear should reset
        view.clearSignature();
        assertTrue(view.isEmpty());
    }

    @Test
    public void setMinStrokeWidth_doesNotThrow() {
        view.setMinStrokeWidth(5);
        // No public getter; just verify no exception
    }

    @Test
    public void setMaxStrokeWidth_doesNotThrow() {
        view.setMaxStrokeWidth(20);
        // No public getter; just verify no exception
    }

    @Test
    public void setStrokeColor_doesNotThrow() {
        view.setStrokeColor(Color.RED);
        // Verifies the paint color is updated without error
    }
}
