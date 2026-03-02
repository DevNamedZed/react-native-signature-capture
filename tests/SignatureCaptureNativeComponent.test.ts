import NativeSignatureView, {
  Commands,
} from '../src/SignatureCaptureNativeComponent';

describe('SignatureCaptureNativeComponent', () => {
  it('exports a component', () => {
    expect(NativeSignatureView).toBeDefined();
  });

  it('component is registered as RSSignatureView', () => {
    // The mock sets displayName to the registered name
    expect((NativeSignatureView as any).displayName).toBe('RSSignatureView');
  });

  it('exports Commands object', () => {
    expect(Commands).toBeDefined();
    expect(typeof Commands).toBe('object');
  });

  it('Commands has saveImage function', () => {
    expect(typeof Commands.saveImage).toBe('function');
  });

  it('Commands has resetImage function', () => {
    expect(typeof Commands.resetImage).toBe('function');
  });

  it('Commands has exactly saveImage and resetImage', () => {
    const keys = Object.keys(Commands).sort();
    expect(keys).toEqual(['resetImage', 'saveImage']);
  });

  it('Commands functions accept a ref argument without throwing', () => {
    const spy = jest.spyOn(console, 'error').mockImplementation(() => {});
    const fakeRef = {} as any;
    expect(() => Commands.saveImage(fakeRef)).not.toThrow();
    expect(() => Commands.resetImage(fakeRef)).not.toThrow();
    spy.mockRestore();
  });
});
