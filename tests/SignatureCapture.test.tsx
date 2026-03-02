import React, { createRef } from 'react';
import { render } from '@testing-library/react-native';
import SignatureCapture from '../src/SignatureCapture';
import type { SignatureCaptureRef } from '../src/SignatureCapture';
import * as NativeComponent from '../src/SignatureCaptureNativeComponent';

describe('SignatureCapture', () => {
  let saveImageSpy: jest.SpyInstance;
  let resetImageSpy: jest.SpyInstance;

  beforeEach(() => {
    jest.clearAllMocks();
    saveImageSpy = jest.spyOn(NativeComponent.Commands, 'saveImage').mockImplementation(() => {});
    resetImageSpy = jest.spyOn(NativeComponent.Commands, 'resetImage').mockImplementation(() => {});
  });

  afterEach(() => {
    saveImageSpy.mockRestore();
    resetImageSpy.mockRestore();
  });

  // --- Rendering ---

  it('mounts without crashing', () => {
    const { toJSON } = render(<SignatureCapture />);
    expect(toJSON()).toBeTruthy();
  });

  it('renders an RSSignatureView native component', () => {
    const { toJSON } = render(<SignatureCapture />);
    const tree = toJSON();
    expect(tree?.type).toBe('RSSignatureView');
  });

  it('has displayName "SignatureCapture"', () => {
    expect(SignatureCapture.displayName).toBe('SignatureCapture');
  });

  // --- Props forwarding ---

  it('forwards style prop', () => {
    const style = { width: 300, height: 200 };
    const { toJSON } = render(<SignatureCapture style={style} />);
    const tree = toJSON();
    expect(tree?.props.style).toEqual(style);
  });

  it('forwards boolean props when true', () => {
    const { toJSON } = render(
      <SignatureCapture
        rotateClockwise={true}
        square={true}
        saveImageFileInExtStorage={true}
        showBorder={true}
        showNativeButtons={true}
        showTitleLabel={true}
      />
    );
    const tree = toJSON();
    expect(tree?.props.rotateClockwise).toBe(true);
    expect(tree?.props.square).toBe(true);
    expect(tree?.props.saveImageFileInExtStorage).toBe(true);
    expect(tree?.props.showBorder).toBe(true);
    expect(tree?.props.showNativeButtons).toBe(true);
    expect(tree?.props.showTitleLabel).toBe(true);
  });

  it('forwards boolean props when false', () => {
    const { toJSON } = render(
      <SignatureCapture
        rotateClockwise={false}
        square={false}
        saveImageFileInExtStorage={false}
        showBorder={false}
        showNativeButtons={false}
        showTitleLabel={false}
      />
    );
    const tree = toJSON();
    expect(tree?.props.rotateClockwise).toBe(false);
    expect(tree?.props.square).toBe(false);
    expect(tree?.props.saveImageFileInExtStorage).toBe(false);
    expect(tree?.props.showBorder).toBe(false);
    expect(tree?.props.showNativeButtons).toBe(false);
    expect(tree?.props.showTitleLabel).toBe(false);
  });

  it('forwards numeric props', () => {
    const { toJSON } = render(
      <SignatureCapture maxSize={800} minStrokeWidth={2} maxStrokeWidth={10} />
    );
    const tree = toJSON();
    expect(tree?.props.maxSize).toBe(800);
    expect(tree?.props.minStrokeWidth).toBe(2);
    expect(tree?.props.maxStrokeWidth).toBe(10);
  });

  it('forwards string props', () => {
    const { toJSON } = render(
      <SignatureCapture
        viewMode="landscape"
        strokeColor="#FF0000"
        backgroundColor="#00FF00"
      />
    );
    const tree = toJSON();
    expect(tree?.props.viewMode).toBe('landscape');
    expect(tree?.props.strokeColor).toBe('#FF0000');
    expect(tree?.props.backgroundColor).toBe('#00FF00');
  });

  // --- Events ---

  it('wraps onSaveEvent to unwrap nativeEvent', () => {
    const handler = jest.fn();
    const { toJSON } = render(<SignatureCapture onSaveEvent={handler} />);
    const tree = toJSON();

    const nativeHandler = tree?.props.onSaveEvent;
    expect(nativeHandler).toBeDefined();

    const fakeNativeEvent = {
      nativeEvent: { pathName: '/tmp/sig.png', encoded: 'base64data' },
    };
    nativeHandler(fakeNativeEvent);

    expect(handler).toHaveBeenCalledWith({
      pathName: '/tmp/sig.png',
      encoded: 'base64data',
    });
  });

  it('wraps onDragEvent to unwrap nativeEvent', () => {
    const handler = jest.fn();
    const { toJSON } = render(<SignatureCapture onDragEvent={handler} />);
    const tree = toJSON();

    const nativeHandler = tree?.props.onDragEvent;
    expect(nativeHandler).toBeDefined();

    nativeHandler({ nativeEvent: { dragged: true } });
    expect(handler).toHaveBeenCalledWith({ dragged: true });
  });

  it('passes undefined for onSaveEvent when no callback provided', () => {
    const { toJSON } = render(<SignatureCapture />);
    const tree = toJSON();
    expect(tree?.props.onSaveEvent).toBeUndefined();
  });

  it('passes undefined for onDragEvent when no callback provided', () => {
    const { toJSON } = render(<SignatureCapture />);
    const tree = toJSON();
    expect(tree?.props.onDragEvent).toBeUndefined();
  });

  // --- Ref / Imperative handle ---

  it('saveImage calls Commands.saveImage with the native ref', () => {
    const ref = createRef<SignatureCaptureRef>();
    render(<SignatureCapture ref={ref} />);

    expect(ref.current).toBeTruthy();
    ref.current!.saveImage();

    expect(saveImageSpy).toHaveBeenCalledTimes(1);
  });

  it('resetImage calls Commands.resetImage with the native ref', () => {
    const ref = createRef<SignatureCaptureRef>();
    render(<SignatureCapture ref={ref} />);

    expect(ref.current).toBeTruthy();
    ref.current!.resetImage();

    expect(resetImageSpy).toHaveBeenCalledTimes(1);
  });

  it('ref exposes exactly saveImage and resetImage', () => {
    const ref = createRef<SignatureCaptureRef>();
    render(<SignatureCapture ref={ref} />);

    const methods = Object.keys(ref.current!);
    expect(methods.sort()).toEqual(['resetImage', 'saveImage']);
  });

  // --- Edge cases ---

  it('does not crash when saveImage called before native ref available', () => {
    const ref = createRef<SignatureCaptureRef>();
    render(<SignatureCapture ref={ref} />);

    // Should not throw even if internal nativeRef were null
    expect(() => ref.current!.saveImage()).not.toThrow();
  });

  it('does not crash when resetImage called before native ref available', () => {
    const ref = createRef<SignatureCaptureRef>();
    render(<SignatureCapture ref={ref} />);

    expect(() => ref.current!.resetImage()).not.toThrow();
  });

  it('renders with no props without error', () => {
    expect(() => render(<SignatureCapture />)).not.toThrow();
  });

  it('can render multiple instances', () => {
    const { toJSON } = render(
      <>
        <SignatureCapture />
        <SignatureCapture />
      </>
    );
    expect(toJSON()).toBeTruthy();
  });
});
