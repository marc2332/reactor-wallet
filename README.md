## Solana Mobile Wallet

A mobile wallet for Solana made in flutter

Features:
- Watch over any address
- Import wallets with it's seedphrase (devnet only for now)
- Create new wallets (devnet only for now)

TODO / Ideas:
- [ ] **A name for the app**
- [ ] Seedphrases encryption
- [ ] Mainnet/betanet/custom net support besides devnet
- [x] Ability to name and rename imported and created wallets, and watched addresses
- [x] Ability to make transactions
- [x] Ability to refresh the current SOL value by pulling down
- [ ] Option to use another currency besides dollar as equivalent value
- [ ] Display latest transactions (waiting for https://github.com/cryptoplease/cryptoplease-dart/pull/83)
- [ ] Better project organization
- [ ] Ability to easily share an address (QR?)
- [ ] Have some UI tweaking options, like themes.
- [ ] Unit tests
- [ ] Ability to display NFTs owned by a wallet 
- [ ] Upload to https://itsallwidgets.com/

WIP.

### Building

```
flutter build apk --tree-shake-icons --split-per-abi
```

MIT License