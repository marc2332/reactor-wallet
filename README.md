## Solana Mobile Wallet

A mobile wallet for Solana made in flutter

Features:
- Watch over any address
- Display SPL Tokens
- Import wallets with it's seedphrase (devnet only for now)
- Create new wallets (devnet only for now)

TODO / Ideas:
- [ ] **A name for the app**
- [ ] Seedphrases encryption
- [x] Mainnet/betanet/custom net support besides devnet
- [x] Ability to name and rename imported and created wallets, and watched addresses
- [x] Ability to make SOL transactions
- [x] Ability to refresh the current SOL value by pulling down
- [ ] Option to use another currency besides USD as equivalent currency
- [x] Display latest transactions
- [ ] Better project organization
- [ ] Ability to easily share an address (QR?)
- [ ] Have some UI tweaking options, like themes.
- [ ] Unit tests
- [x] Display owned tokens
- [ ] Ability to display NFTs owned by a wallet 
- [ ] Upload to https://itsallwidgets.com/
- [ ] Ability to add a small note when making transactions
- [ ] Ability to make transactions with SPL Tokens
- [ ] Better UX (specially when creating accounts)

WIP.

### Support this project
You can support this project by donating any ammount you want to these addresses;

Solana: `u5GzDDXyzhB9zA8vSHuEow5mQJ6Tk3kC4Bn2T9dp6nX3U`
Bitcoin: `1HCBeYD564Y3AjQ3Ci6Fp2zosfZvevJuu6`

### Building

```
flutter build apk --tree-shake-icons --split-per-abi
```

#### Format
```
dart format . --line-length 120
```

MIT License