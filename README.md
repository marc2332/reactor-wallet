## 💳 Reactor Wallet

Rector Wallet is an **experimental** wallet for the [Solana Blockchain](https://solana.com) made with Flutter.

Its on **alpha** stage, be careful when using it.

**NOTE**: This project was started as side project, but, it has also been submitted to [Solana Riptide Hackathon](https://solana.com/riptide).

### 😎 Features
- Experimental [Solana Pay](https://solanapay.com) integration
- Watch over any address you want
- Display SPL Tokens and transactions
- Import and create multiple wallets
- Show the USD equivalent of the address balance and all it's tokens combined
- You can see collectives (aka NFTs)

It should work fine on **Android** and **Windows**, I haven't tried on the other platforms.

![Example screenshot](screenshot.png)

### 🎉 Support this project
You can support this project by donating any amount you want to these addresses;

- Solana: `5GzDDXyzhB9zA8vSHuEow5mQJ6Tk3kC4Bn2T9dp6nX3U`
- Bitcoin: `1HCBeYD564Y3AjQ3Ci6Fp2zosfZvevJuu6`

### 🏭 Building

For Android:
```
flutter build apk --tree-shake-icons --split-per-abi
```

For Windows:
```
flutter build windows --tree-shake-icons
```

### 📝 Formatting
```
dart format . --line-length 100
```

### 🤔 To-do / Ideas
- [x] **A name for the app**
- [x] Handle `solana:` links, this way the wallet will be prompted to the user (experimental)
- [x] Add password encryption
- [ ] [Solana Pay](https://solana-pay-docs.vercel.app/core/wallet-integration) integration, implemented, but highly experimental
    - [x] QR Reader
    - [x] SOL Transactions (Experimental)
    - [x] SPL Tokens Transactions (Experimental)
    - [ ] Support for Label, Message, Memo
    - [ ] QR Generator (WIP, like https://github.com/solana-labs/solana-pay/tree/master/point-of-sale does )
        - [x] SOL transactions (Experimental)
        - [x] SPL Tokens transaction (Experimental)
        - [ ] Compare the new received transaction by finding it with the reference, just to make sure the amount is correct
- [x] Mainnet/betanet/custom net support besides devnet
- [x] Ability to name and rename imported and created wallets, and watched addresses
- [x] Ability to make SOL transactions
- [x] Ability to refresh the current SOL value by pulling down
- [ ] Option to use another currency besides USD as equivalent currency
- [x] Display latest transactions
- [ ] Better project organization
- [ ] Ability to easily share an address (QR?)
- [x] Have some UI tweaking options, like themes.
- [ ] Unit tests (WIP)
- [x] Display owned tokens
- [x] Ability to display NFTs owned by an address 
- [x] Upload to https://itsallwidgets.com/ (done: https://itsallwidgets.com/reactor-wallet)
- [ ] Ability to add a small note when making transactions
- [x] Ability to make transactions with SPL Tokens
- [ ] Better UX (specially when creating accounts)
- [x] Transactions Timestamps
- [ ] Better Windows UX (e.g, using split views)
- [ ] Send notifications when the app is closed and new transactions are received
- [ ] Add a contacts list
- [ ] Ability to update the encryption password once it's set

MIT License
