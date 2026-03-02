import React, { useState, useRef, forwardRef, useImperativeHandle } from 'react';
import { View, Text, Modal, Platform } from 'react-native';
import SignatureCapture, { type SignatureCaptureRef, type SaveEvent, type DragEvent } from 'react-native-signature-capture';

const toolbarHeight = Platform.select({
  android: 0,
  ios: 22,
});

const modalViewStyle = {
  paddingTop: toolbarHeight,
  flex: 1,
} as const;

export interface SignatureViewRef {
  show: (display: boolean) => void;
}

interface SignatureViewProps {
  rotateClockwise?: boolean;
  onSave?: (result: SaveEvent) => void;
}

const SignatureView = forwardRef<SignatureViewRef, SignatureViewProps>(
  ({ rotateClockwise, onSave }, ref) => {
    const [visible, setVisible] = useState(false);
    const signatureRef = useRef<SignatureCaptureRef>(null);

    useImperativeHandle(ref, () => ({
      show(display: boolean) {
        setVisible(display);
      },
    }));

    const onDragEvent = (_event: DragEvent) => {
      // This callback will be called when the user enters signature
    };

    const onSaveEvent = (result: SaveEvent) => {
      onSave?.(result);
    };

    const isAndroid = Platform.OS === 'android';

    return (
      <Modal
        transparent={false}
        visible={visible}
        onRequestClose={() => setVisible(false)}>
        <View style={modalViewStyle}>
          <View style={{ padding: 10, flexDirection: 'row' }}>
            <Text onPress={() => setVisible(false)}>{' x '}</Text>
            <View style={{ flex: 1, alignItems: 'center' }}>
              <Text style={{ fontSize: 14 }}>Please write your signature.</Text>
            </View>
          </View>
          <SignatureCapture
            ref={signatureRef}
            style={{ flex: 1, width: '100%' }}
            onDragEvent={onDragEvent}
            onSaveEvent={onSaveEvent}
            rotateClockwise={rotateClockwise}
            backgroundColor={isAndroid ? '#ff00ff' : 'transparent'}
            strokeColor={isAndroid ? '#ffffff' : '#000000'}
            minStrokeWidth={isAndroid ? 4 : undefined}
            maxStrokeWidth={isAndroid ? 4 : undefined}
          />
        </View>
      </Modal>
    );
  }
);

SignatureView.displayName = 'SignatureView';

export default SignatureView;
