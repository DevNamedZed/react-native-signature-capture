import type { HostComponent, ViewProps } from 'react-native';
import type { DirectEventHandler, Int32, WithDefault } from 'react-native/Libraries/Types/CodegenTypes';
export interface SaveEvent {
    pathName: string;
    encoded: string;
}
export interface DragEvent {
    dragged: boolean;
}
export interface NativeProps extends ViewProps {
    rotateClockwise?: WithDefault<boolean, false>;
    square?: WithDefault<boolean, false>;
    saveImageFileInExtStorage?: WithDefault<boolean, false>;
    viewMode?: string;
    showBorder?: WithDefault<boolean, true>;
    showNativeButtons?: WithDefault<boolean, true>;
    showTitleLabel?: WithDefault<boolean, true>;
    maxSize?: WithDefault<Int32, 500>;
    minStrokeWidth?: Int32;
    maxStrokeWidth?: Int32;
    strokeColor?: string;
    backgroundColor?: string;
    onSaveEvent?: DirectEventHandler<SaveEvent>;
    onDragEvent?: DirectEventHandler<DragEvent>;
}
type ComponentType = HostComponent<NativeProps>;
interface NativeCommands {
    saveImage: (viewRef: React.ElementRef<ComponentType>) => void;
    resetImage: (viewRef: React.ElementRef<ComponentType>) => void;
}
export declare const Commands: NativeCommands;
declare const _default: ComponentType;
export default _default;
//# sourceMappingURL=SignatureCaptureNativeComponent.d.ts.map