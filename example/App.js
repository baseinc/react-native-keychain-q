/**
 * Sample React Native App
 *
 * adapted from App.js generated by the following command:
 *
 * react-native init example
 *
 * https://github.com/facebook/react-native
 */

import React, { Component } from 'react';
import { Platform, StyleSheet, Text, View, ScrollView, SafeAreaView } from 'react-native';
import KeychainQ from 'react-native-keychain-q';

const server = 'https://keychain-q.example.com';
const creds = [
  {account: 'bob', password: 'pass1'},
  {account: 'alice', password: 'pass2'}
]

export default class App extends Component<{}> {
  state = {
    status: 'starting',
    message: '--',
    existsAnyAccount: '',
    existsAccount: '',
    notExistsAccount: '',
    credentials: null,
    allCredentials: []
  };
  componentDidMount() {
      (async () => {
        try {
          const t = await KeychainQ.fetchSupportedBiometryType();
          this.setState({biometryType: t});

          await KeychainQ.saveInternetPassword(server, creds[0].account, creds[0].password, {accessible: 'whenUnlocked'});
          await KeychainQ.saveInternetPassword(server, creds[1].account, creds[1].password, {accessible: 'afterFirstUnlock', accessControls: ['userPresence']});
          const existsAnyAccount = await KeychainQ.containsAnyInternetPassword(server, {});
          const existsAccount = await KeychainQ.containsAnyInternetPassword(server, {account: creds[0].account});
          const notExistsAccount = await KeychainQ.containsAnyInternetPassword(server, {account: 'foo'});
          const credentials = await KeychainQ.findInternetPassword(server, {account: creds[0].account});
          const allCredentials = await KeychainQ.retrieveInternetPasswords(server, {authenticationPrompt: 'this is a test!!!!!11'});
          await KeychainQ.retrieveInternetPasswords(server, {});
          this.setState({
            biometryType: t,
            existsAnyAccount: existsAnyAccount ? 'exists' : 'not exists',
            existsAccount: existsAccount ? 'exists' : 'not exists',
            notExistsAccount: notExistsAccount ? 'exists' : 'not exists',
            credentials: credentials,
            allCredentials: allCredentials.map((item) => ["account=", item.account, ", password=", item.password].join('')).join('\n')
          });
          await KeychainQ.resetInternetPasswords(server, {});
          await KeychainQ.resetInternetPasswords(null, {});
          const cred = await KeychainQ.findInternetPassword(server, {account: creds[0].account});
          console.log(cred);
        } catch (error) {
          console.warn(error);
        }
      })();
  }

  componentDidUpdate() {
    console.log(this.state)
  }
  render() {
    return (
      <SafeAreaView style={styles.container}>
        <ScrollView>
          <Text style={styles.welcome}>☆KeychainQ example☆</Text>
          <Text style={styles.welcome}>Biometry Type</Text>
          <Text style={styles.instructions}>{this.state.biometryType}</Text>
          <Text style={styles.welcome}>Password? in {server}</Text>
          <Text style={styles.instructions}>{this.state.existsAnyAccount}</Text>
          <Text style={styles.welcome}>Password? in {server} and {creds[0].account}</Text>
          <Text style={styles.instructions}>{this.state.existsAccount}</Text>
          <Text style={styles.welcome}>Password? in {server} and unknown user</Text>
          <Text style={styles.instructions}>{this.state.notExistsAccount}</Text>
          <Text style={styles.welcome}>credentials in {server} and {creds[0].account}</Text>
          <Text style={styles.instructions}>{this.state.credentials && ["account=", this.state.credentials.account, ", password=", this.state.credentials.password].join('') }</Text>
          <Text style={styles.welcome}>credentials in {server}</Text>
          <Text style={styles.instructions}>{this.state.allCredentials}</Text>
        </ScrollView>
      </SafeAreaView>
    );
  }
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
});
