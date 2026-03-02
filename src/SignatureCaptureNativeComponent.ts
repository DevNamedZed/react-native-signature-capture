import type { HostComponent, ViewProps } from 'react-native';
import type {
  DirectEventHandler,
  Int32,
  WithDefault,
} from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';

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

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['saveImage', 'resetImage'],
});

export default codegenNativeComponent<NativeProps>('RSSignatureView', {
  interfaceOnly: true,
}) as ComponentType;
