package com.rssignaturecapture;

import static org.junit.Assert.*;

import android.app.Activity;
import android.view.View;
import android.widget.LinearLayout;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = 30)
public class RSSignatureCaptureMainViewTest {

    private RSSignatureCaptureMainView mainView;
    private Activity activity;

    @Before
    public void setUp() {
        activity = Robolectric.buildActivity(Activity.class).create().get();
        mainView = new RSSignatureCaptureMainView(activity, activity);
    }

    @Test
    public void constructor_setsVerticalOrientation() {
        assertEquals(LinearLayout.VERTICAL, mainView.getOrientation());
    }

    @Test
    public void setSaveFileInExtStorage_storesValue() {
        mainView.setSaveFileInExtStorage(true);
        // No public getter, but verify it doesn't throw
        mainView.setSaveFileInExtStorage(false);
    }

    @Test
    public void setMaxSize_storesValue() {
        mainView.setMaxSize(1000);
        // Verify via getResizedBitmap behavior - maxSize is stored internally
        // This just verifies no exception is thrown
    }

    @Test
    public void setShowNativeButtons_false_hidesButtons() {
        mainView.setShowNativeButtons(false);
        // The buttons layout should be GONE
        View buttonsLayout = mainView.getChildAt(0);
        assertEquals(View.GONE, buttonsLayout.getVisibility());
    }

    @Test
    public void setShowNativeButtons_true_showsButtons() {
        mainView.setShowNativeButtons(false);
        mainView.setShowNativeButtons(true);
        View buttonsLayout = mainView.getChildAt(0);
        assertEquals(View.VISIBLE, buttonsLayout.getVisibility());
    }

    @Test
    public void getSignatureView_returnsNonNull() {
        assertNotNull(mainView.getSignatureView());
    }

    @Test
    public void reset_delegatesToSignatureView() {
        RSSignatureCaptureView sigView = mainView.getSignatureView();
        assertNotNull(sigView);
        // reset() calls signatureView.clearSignature() which calls clear()
        // Just verify it doesn't throw
        mainView.reset();
        assertTrue(sigView.isEmpty());
    }
}
