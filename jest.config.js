module.exports = {
  preset: 'react-native',
  testMatch: ['<rootDir>/tests/**/*.(test|spec).(ts|tsx)'],
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': [
      'babel-jest',
      {
        presets: [
          'module:@react-native/babel-preset',
          '@babel/preset-typescript',
        ],
      },
    ],
  },
  transformIgnorePatterns: [
    'node_modules/(?!(react-native|@react-native)/)',
  ],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json'],
};
