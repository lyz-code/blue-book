
# Install

```bash
sudo apt-get install dino-im
```

## Improve security

### Disable automatic OMEMO key acceptance
Dino automatically accepts new OMEMO keys from your own other devices and your chat partners by default. This default behaviour leads to the fact that the admin of the XMPP server could inject own public OMEMO keys without user verification, which enables the owner of the associated private OMEMO keys to decrypt your OMEMO secured conversation without being easily noticed.

To prevent this, two actions are required, the second consists of several steps and must be taken for each new chat partner.

- First, the automatic acceptance of new keys from your own other devices must be deactivated. Configure this in the account settings of your own accounts.
- Second, the automatic acceptance of new keys from your chat partners must be deactivated. Configure this in the contact details of every chat partner. Be aware that in the case of group chats, the entire communication can be decrypted unnoticed if even one partner does not actively deactivate automatic acceptance of new OMEMO keys.

Always confirm new keys from your chat partner before accepting them manually

### Dino does not use encryption by default

You have to initially enable encryption in the conversation window by clicking the lock-symbol and choose OMEMO. Future messages and file transfers to this contact will be encrypted with OMEMO automatically.

- Every chat partner has to enable encryption separately.
- If only one of two chat partner has activated OMEMO, only this part of the communication will be encrypted. The same applies with file transfers.
- If you get a message "This contact does not support OMEMO" make sure that your chatpartner has accepted the request to add him to your contact list and you accepted vice versa

## [Install in Tails](https://t-hinrichs.net/DinoTails/DinoTails_recent.html)

If you have more detailed follow [this article](https://t-hinrichs.net/DinoTails/DinoTails_recent.html) at the same time as you read this one. That one is more outdated but more detailed.

- Boot a clean Tails
- Create and configure the Persistent Storage
- Restart Tails and open the Persistent Storage

- Configure the persistence of the directory: 
    ```bash
    echo -e '/home/amnesia/.local/share/dino source=dino' | sudo tee -a /live/persistence/TailsData_unlocked/persistence.conf > /dev/null
    ```
- Restart Tails

- Install the application:
    ```bash
    sudo apt-get update
    sudo apt-get install dino-im
    ```
- Configure the `dino-im` alias to use `torsocks`

    ```bash
    sudo echo 'alias dino="torsocks dino-im &> /dev/null &"' >> /live/persistence/TailsData_unlocked/dotfiles/.bashrc
    echo 'alias dino="torsocks dino-im &> /dev/null &"' >> ~/.bashrc
    ```

