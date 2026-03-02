import DefaultExport from '../src/index';
import SignatureCaptureDirect from '../src/SignatureCapture';

describe('index exports', () => {
  it('default export is SignatureCapture', () => {
    expect(DefaultExport).toBe(SignatureCaptureDirect);
  });

  it('default export has correct displayName', () => {
    expect(DefaultExport.displayName).toBe('SignatureCapture');
  });

  it('default export has $$typeof indicating a React element type', () => {
    // forwardRef components have a $$typeof symbol
    expect((DefaultExport as any).$$typeof).toBeDefined();
    expect(typeof (DefaultExport as any).$$typeof).toBe('symbol');
  });

  it('re-export identity matches direct import', () => {
    // The default export from index should be the exact same reference
    expect(DefaultExport).toStrictEqual(SignatureCaptureDirect);
  });

  it('type exports are importable without error', () => {
    // This test validates that the TypeScript type exports compile correctly.
    // If the types were broken, this file would fail to compile.
    // We verify the module itself can be imported.
    const indexModule = require('../src/index');
    expect(indexModule).toBeDefined();
    expect(indexModule.default).toBeDefined();
  });
});
