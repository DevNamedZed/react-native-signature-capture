import React, { useState, useRef } from 'react';
import {
  View,
  StyleSheet,
  Button,
  Text,
  Image,
  TouchableOpacity,
} from 'react-native';
import type { SaveEvent } from 'react-native-signature-capture';
import SignatureView, { type SignatureViewRef } from './SignatureView';

const ExampleApp = () => {
  const [data, setData] = useState<string | null>(null);
  const signatureView = useRef<SignatureViewRef>(null);

  const onSave = (result: SaveEvent) => {
    setData(`data:image/png;base64,${result.encoded}`);
    signatureView.current?.show(false);
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={() => {
          signatureView.current?.show(true);
        }}>
        <View>
          <Text style={styles.titleText}>
            {data ? 'Your signature:' : 'Click to sign'}
          </Text>
          {data && (
            <View style={styles.imageContainer}>
              <Image style={styles.previewImage} source={{ uri: data }} />
              <Button title="Clear" onPress={() => setData(null)} />
            </View>
          )}
        </View>
      </TouchableOpacity>
      <SignatureView
        ref={signatureView}
        rotateClockwise={true}
        onSave={onSave}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: '#F8F8F8',
    alignItems: 'center',
  },
  titleText: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  imageContainer: {
    marginTop: 10,
    backgroundColor: 'white',
  },
  previewImage: {
    width: 300,
    height: 300,
    resizeMode: 'contain',
  },
});

export default ExampleApp;
