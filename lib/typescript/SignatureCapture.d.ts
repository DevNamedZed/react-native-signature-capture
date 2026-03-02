import type { ViewStyle, StyleProp } from 'react-native';
import { type SaveEvent, type DragEvent } from './SignatureCaptureNativeComponent';
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
declare const SignatureCapture: any;
export default SignatureCapture;
//# sourceMappingURL=SignatureCapture.d.ts.map