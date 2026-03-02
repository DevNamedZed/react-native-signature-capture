package com.rssignaturecapture;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import org.junit.Before;
import org.junit.Test;

import java.util.Map;

public class RSSignatureCaptureViewManagerTest {

    private RSSignatureCaptureViewManager manager;

    @Before
    public void setUp() {
        manager = new RSSignatureCaptureViewManager();
    }

    @Test
    public void getName_returnsRSSignatureView() {
        assertEquals("RSSignatureView", manager.getName());
    }

    @Test
    public void getCommandsMap_containsSaveImage() {
        Map<String, Integer> commands = manager.getCommandsMap();
        assertNotNull(commands);
        assertTrue(commands.containsKey("saveImage"));
        assertEquals(Integer.valueOf(1), commands.get("saveImage"));
    }

    @Test
    public void getCommandsMap_containsResetImage() {
        Map<String, Integer> commands = manager.getCommandsMap();
        assertNotNull(commands);
        assertTrue(commands.containsKey("resetImage"));
        assertEquals(Integer.valueOf(2), commands.get("resetImage"));
    }

    @Test
    public void getExportedCustomDirectEventTypeConstants_containsOnSaveEvent() {
        Map<String, Object> events = manager.getExportedCustomDirectEventTypeConstants();
        assertNotNull(events);
        assertTrue(events.containsKey("onSaveEvent"));
    }

    @Test
    public void getExportedCustomDirectEventTypeConstants_containsOnDragEvent() {
        Map<String, Object> events = manager.getExportedCustomDirectEventTypeConstants();
        assertNotNull(events);
        assertTrue(events.containsKey("onDragEvent"));
    }

    @Test
    public void receiveCommand_stringCommand_saveImage() {
        RSSignatureCaptureMainView view = mock(RSSignatureCaptureMainView.class);
        manager.receiveCommand(view, "saveImage", null);
        verify(view).saveImage();
    }

    @Test
    public void receiveCommand_stringCommand_resetImage() {
        RSSignatureCaptureMainView view = mock(RSSignatureCaptureMainView.class);
        manager.receiveCommand(view, "resetImage", null);
        verify(view).reset();
    }

    @Test(expected = IllegalArgumentException.class)
    public void receiveCommand_stringCommand_invalidThrows() {
        RSSignatureCaptureMainView view = mock(RSSignatureCaptureMainView.class);
        manager.receiveCommand(view, "invalidCommand", null);
    }

    @Test
    public void receiveCommand_intCommand_saveImage() {
        RSSignatureCaptureMainView view = mock(RSSignatureCaptureMainView.class);
        manager.receiveCommand(view, RSSignatureCaptureViewManager.COMMAND_SAVE_IMAGE, null);
        verify(view).saveImage();
    }

    @Test
    public void receiveCommand_intCommand_resetImage() {
        RSSignatureCaptureMainView view = mock(RSSignatureCaptureMainView.class);
        manager.receiveCommand(view, RSSignatureCaptureViewManager.COMMAND_RESET_IMAGE, null);
        verify(view).reset();
    }

    @Test(expected = IllegalArgumentException.class)
    public void receiveCommand_intCommand_invalidThrows() {
        RSSignatureCaptureMainView view = mock(RSSignatureCaptureMainView.class);
        manager.receiveCommand(view, 999, null);
    }
}
