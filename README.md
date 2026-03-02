# react-native-signature-capture

A React Native library for capturing signatures. Users sign on the screen and the library returns the signature as a base64-encoded PNG and/or a file path.

This is a modernized fork of the abandoned [RepairShopr/react-native-signature-capture](https://github.com/RepairShopr/react-native-signature-capture), rewritten for React Native 0.73+ with TypeScript, New Architecture (Fabric) support, and Core Graphics rendering on iOS (replacing the deprecated OpenGL ES).

## Requirements

- React Native >= 0.73.0
- React >= 18.0.0
- iOS >= 16.4
- Android SDK 24+ (compileSdk 35)

## Install

```sh
npm install react-native-signature-capture
```

On iOS, run pod install:

```sh
cd ios && pod install
```

Auto-linking handles the rest. No manual linking required.

## Usage

```tsx
import React, { useRef } from 'react';
import { View, Button, StyleSheet } from 'react-native';
import SignatureCapture, {
  type SignatureCaptureRef,
  type SaveEvent,
} from 'react-native-signature-capture';

function SignatureScreen() {
  const signatureRef = useRef<SignatureCaptureRef>(null);

  const handleSave = (event: SaveEvent) => {
    console.log('Base64:', event.encoded);
    console.log('File path:', event.pathName);
  };

  return (
    <View style={styles.container}>
      <SignatureCapture
        ref={signatureRef}
        style={styles.signature}
        onSaveEvent={handleSave}
        onDragEvent={() => console.log('User is signing')}
        showNativeButtons={false}
        showTitleLabel={false}
        viewMode="portrait"
      />
      <View style={styles.buttons}>
        <Button title="Save" onPress={() => signatureRef.current?.saveImage()} />
        <Button title="Reset" onPress={() => signatureRef.current?.resetImage()} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  signature: { flex: 1, borderColor: '#000', borderWidth: 1 },
  buttons: { flexDirection: 'row', justifyContent: 'space-around', padding: 10 },
});
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `saveImageFileInExtStorage` | `boolean` | `false` | Save the image file to external storage (Android). Warning: image will be visible in gallery apps. |
| `showBorder` | `boolean` | `true` | Show a dashed border around the signature area (iOS only). |
| `showNativeButtons` | `boolean` | `true` | Show native "Save" and "Reset" buttons. |
| `showTitleLabel` | `boolean` | `true` | Show the "x\_ \_ \_" placeholder indicating where to sign. |
| `viewMode` | `string` | `"portrait"` | `"portrait"` or `"landscape"` — locks screen orientation. |
| `maxSize` | `number` | `500` | Max dimension of the output image (maintains aspect ratio). |
| `minStrokeWidth` | `number` | — | Minimum stroke line width (Android only). |
| `maxStrokeWidth` | `number` | — | Maximum stroke line width (Android only). |
| `backgroundColor` | `string` | `"#FFFFFF"` | Background color. Supports `"transparent"`. |
| `strokeColor` | `string` | `"#000000"` | Signature stroke color. |

## Events

| Event | Payload | Description |
|-------|---------|-------------|
| `onSaveEvent` | `{ pathName: string, encoded: string }` | Fired when `saveImage()` is called. Returns the file path and base64-encoded PNG. |
| `onDragEvent` | `{ dragged: boolean }` | Fired when the user draws on the canvas. |

## Ref Methods

| Method | Description |
|--------|-------------|
| `saveImage()` | Triggers image save. Result is returned via `onSaveEvent`. |
| `resetImage()` | Clears the signature canvas. |

## TypeScript

The library exports the following types:

```ts
import type {
  SignatureCaptureProps,
  SignatureCaptureRef,
  SaveEvent,
  DragEvent,
} from 'react-native-signature-capture';
```

## Architecture Support

- **New Architecture (Fabric):** Fully supported via Codegen spec
- **Old Architecture (Paper):** Supported via interop layer

## License

ISC
