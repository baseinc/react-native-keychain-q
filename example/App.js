/**
 * Sample React Native App
 *
 * adapted from App.js generated by the following command:
 *
 * react-native init example
 *
 * https://github.com/facebook/react-native
 * @format
 * @flow
 */

import React, {useEffect, useState, useCallback} from 'react';
import {
  StyleSheet,
  ScrollView,
  SafeAreaView,
  View,
  Text,
  TextInput,
  Button,
  Switch,
} from 'react-native';
import {
  fetchSupportedBiometryType,
  saveInternetPassword,
  findInternetPassword,
  removeInternetPassword,
  getBiometryTypeLabel,
  retrieveInternetPasswords,
} from 'react-native-keychain-q';

const server = 'https://keychain-q.example.com';
const items = [
  {account: 'bob', password: 'pass1'},
  {account: 'alice', password: 'pass2'},
];

export default function App() {
  const [debugLog, setDebugLog] = useState('-----');
  const [retrieveRequired, setRetrieveRequired] = useState(true);
  const [allCredentials, setAllCredentials] = useState([]);
  useEffect(() => {
    let ignored = false;
    (async () => {
      try {
        if (ignored) {
          return;
        }
        if (!retrieveRequired) {
          return;
        }
        const all = await retrieveInternetPasswords(server);
        console.log(all);
        setRetrieveRequired(false);
        setAllCredentials(all || []);
      } catch (error) {
        console.warn(error);
      }
    })();
    return () => {
      ignored = false;
    };
  }, [retrieveRequired]);
  const [useBiometry, setUseBiometry] = useState({
    label: undefined,
    disabled: true,
    used: false,
  });
  const useBiometrySwitchOnChange = useCallback(enabled => {
    setUseBiometry(state => ({...state, used: enabled}));
  }, []);

  const [biometryType, setBiometryType] = useState();
  useEffect(() => {
    let ignored = false;
    (async () => {
      try {
        const result = await fetchSupportedBiometryType();
        if (!ignored) {
          setBiometryType(result);
          if (['faceID', 'touchID'].includes(result)) {
            setUseBiometry(state => ({
              ...state,
              label: getBiometryTypeLabel(biometryType),
              disabled: false,
            }));
          }
        }
      } catch (error) {
        console.warn(error);
      }
    })();
    return () => {
      ignored = true;
    };
  }, [biometryType]);

  const addCallback = useCallback(
    index => {
      const item = items[index];
      (async () => {
        try {
          const useBio = useBiometry.used;
          const opts = useBiometry.used
            ? {
                accessControls: ['userPresence'],
                deviceOwnerAuthPolicy: 'biometrics',
              }
            : undefined;
          console.log(useBio);
          await saveInternetPassword(server, item.account, item.password, opts);
          setDebugLog('Added credentials ' + '#' + index);
          setTimeout(() => {
            setRetrieveRequired(true);
          }, 1000);
        } catch (error) {
          Object.getOwnPropertyNames(error).forEach(prop => {
            console.log(prop + ' => ' + error[prop]);
            if (prop === 'userInfo') {
              console.log(JSON.stringify(error[prop], null, 2));
            }
          });
          console.warn(error);
        }
      })();
    },
    [useBiometry.used],
  );
  const readCallback = useCallback(index => {
    const item = items[index];
    (async () => {
      try {
        const credentials = await findInternetPassword(server, {
          account: item.account,
        });
        if (credentials) {
          setDebugLog(
            'Read credentials #' +
              index +
              ': ' +
              credentials.account +
              '/' +
              credentials.password,
          );
        } else {
          setDebugLog('Not found credentials #' + index);
        }
      } catch (error) {
        Object.getOwnPropertyNames(error).forEach(prop => {
          console.log(prop + ' => ' + error[prop]);
          if (prop === 'userInfo') {
            console.log(JSON.stringify(error[prop], null, 2));
          }
        });
        console.warn(error);
      }
    })();
  }, []);
  const deleteCallback = useCallback(index => {
    const item = items[index];
    (async () => {
      try {
        await removeInternetPassword(server, item.account);
        setDebugLog('Deleted credentials ' + '#' + index);
        setTimeout(() => {
          setRetrieveRequired(true);
        }, 0);
      } catch (error) {
        console.warn(error);
      }
    })();
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <View>
        <Text style={styles.welcome}>☆KeychainQ example☆</Text>
        <Text style={styles.instructions}>{debugLog}</Text>
        <Text style={styles.welcome}>server example</Text>
        <Text style={styles.instructions}>{server}</Text>
        <Text style={styles.welcome}>Test accounts</Text>
        {items.map((item, index) => (
          <View style={styles.accountInputContainer} key={index}>
            <Text style={styles.accountNumber}>#{index}</Text>
            <TextInput
              editable={false}
              style={styles.accountInput}
              value={item.account}
            />
            <TextInput
              editable={false}
              style={styles.accountInput}
              value={item.password}
            />
            <Button
              disabled={biometryType ? false : true}
              title="Add"
              onPress={() => addCallback(index)}
            />
            <Button
              disabled={biometryType ? false : true}
              title="Read"
              onPress={() => readCallback(index)}
            />
            <Button
              disabled={biometryType ? false : true}
              title="Delete"
              onPress={() => deleteCallback(index)}
            />
          </View>
        ))}
      </View>
      <ScrollView>
        <Text style={styles.welcome}>Biometry Type</Text>
        <View style={styles.instructionsWCtrlContainer}>
          <Text style={[styles.instructions, styles.instructionsWCtrl]}>
            {useBiometry.label && 'Use ' + useBiometry.label + ' when adding'}
          </Text>
          <Switch
            value={useBiometry.used}
            disabled={useBiometry.disabled}
            onValueChange={useBiometrySwitchOnChange}
          />
        </View>
        <Text style={styles.welcome}>Read all credentials from keychain</Text>
        {allCredentials.map((item, index) => (
          <View style={styles.instructionsWCtrlContainer} key={index}>
            <Text style={styles.instructions}>{item.account}</Text>
            <Text style={styles.instructions}>{item.password}</Text>
          </View>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  instructionsWCtrlContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  instructionsWCtrl: {
    padding: 8,
    height: 40,
  },
  accountInputContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    paddingVertical: 8,
  },
  accountNumber: {
    height: 40,
    textAlign: 'center',
  },
  accountInput: {
    borderColor: 'gainsboro',
    borderWidth: 1,
    paddingHorizontal: 8,
    height: 40,
    minWidth: 80,
    borderRadius: 6,
    marginHorizontal: 4,
    color: 'gray',
  },
});
