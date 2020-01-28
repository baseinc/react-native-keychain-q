import { useCallback, useEffect } from 'react';
import { Linking } from 'react-native';

const actionRegExp = /keychain-q:\/\/(\w+)/;
const queryRegExp = /[?&]([^=]+)=([^&]*)/g;
const actions = {
  inspection: undefined,
  'save-internet-password': opts => {
    /* todo */
  },
};

export function useEchoBackWithHandleDeepLink(echoBackHandler) {
  const deepLinkHandler = useCallback(
    args => {
      console.log('linking event', args);
      const url = args.url;
      if (!url) {
        return;
      }
      const action = actionRegExp.exec(url)[1];
      if (!action) {
        return;
      }
      const queries = Array.from(url.split(queryRegExp)).filter(
        (x, i) => i > 0 && typeof x === 'string' && x.length > 0,
      );
      let params = {};
      if (queries.length > 0) {
        params = queries.reduce((result, x, i, aa) => {
          if (i % 2 !== 0) {
            result[aa[i - 1]] = x;
          }
          return result;
        }, {});
      }
      echoBackHandler('catch deepLink ' + args.url);

      // Handle deepLink
    },
    [echoBackHandler],
  );
  useEffect(() => {
    Linking.addEventListener('url', deepLinkHandler);
    return () => {
      Linking.removeEventListener('url', deepLinkHandler);
    };
  }, [deepLinkHandler]);
}
