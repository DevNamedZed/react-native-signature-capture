import React, { forwardRef, useImperativeHandle, useRef } from 'react';
import type { ViewStyle, StyleProp } from 'react-native';
import NativeSignatureView, {
  Commands,
  type SaveEvent,
  type DragEvent,
} from './SignatureCaptureNativeComponent';

export interface SignatureCaptureProps {
  style?: StyleProp<ViewStyle>;
  rotateClockwise?: boolean;
  square?: boolean;
  saveImageFileInExtStorage?: boolean;
  viewMode?: string;
  showBorder?: boolean;
  showNativeButtons?: boolean;
  showTitleLabel?: boolean;
  maxSize?: number;
  minStrokeWidth?: number;
  maxStrokeWidth?: number;
  strokeColor?: string;
  backgroundColor?: string;
  onSaveEvent?: (event: SaveEvent) => void;
  onDragEvent?: (event: DragEvent) => void;
}

export interface SignatureCaptureRef {
  saveImage: () => void;
  resetImage: () => void;
}

const SignatureCapture = forwardRef<SignatureCaptureRef, SignatureCaptureProps>(
  (
    { onSaveEvent, onDragEvent, ...rest },
    ref
  ) => {
    const nativeRef = useRef<React.ElementRef<typeof NativeSignatureView>>(null);

    useImperativeHandle(ref, () => ({
      saveImage() {
        if (nativeRef.current) {
          Commands.saveImage(nativeRef.current);
        }
      },
      resetImage() {
        if (nativeRef.current) {
          Commands.resetImage(nativeRef.current);
        }
      },
    }));

    return (
      <NativeSignatureView
        ref={nativeRef}
        {...rest}
        onSaveEvent={
          onSaveEvent
            ? (event) => onSaveEvent(event.nativeEvent)
            : undefined
        }
        onDragEvent={
          onDragEvent
            ? (event) => onDragEvent(event.nativeEvent)
            : undefined
        }
      />
    );
  }
);

SignatureCapture.displayName = 'SignatureCapture';

export default SignatureCapture;
