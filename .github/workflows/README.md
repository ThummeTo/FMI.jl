# Creation of the SSH deploy key for the CompatHelper

## 1. Create an ssh key pair. 
This command is avaible for Windows (`cmd`) and Linux (`bash`). 
```
ssh-keygen -N "" -f compathelper_key -t ed25519 -C compathelper
```

## 2. Copy the **private** key.
Copy the output to your clipboard.
1. Windows
    
    ```
    type compathelper_key
    ```

1. Linux
    
    ```
    cat compathelper_key
    ```


## 3. Create a GitHub secret.
1. Open the repository on the GitHub page.

1. Click on the **Settings** tab.

1. Click on **Secrets**.

1. Click on **Actions**.

1. Click on the **New repository secret** button.

1. Name the secret `COMPATHELPER_PRIV`.

1. Paste the **private** key as content.

## 4. Copy the **public** key.
Copy the output to your clipboard.

1. Windows
    
    ```
    type compathelper_key.pub
    ```

1. Linux
    
    ```
    cat compathelper_key.pub
    ```


## 5. Create a GitHub deploy key.
1. Open the repository on the GitHub page.

1. Click on the **Settings** tab.

1. Click on **Deploy keys**.

1. Click on the **Add deploy key** button.

1. Name the deploy key `COMPATHELPER_PUB`.

1. Paste the **public** key as content.

1. Enable the write access for the deploy key.

## 6. Delete the ssh key pair.
1. Windows
    
    ```
    del compathelper_key compathelper_key.pub
    ```

1. Linux
    
    ```
    rm -f compathelper_key compathelper_key.pub
    ```

For more Information click [here](https://docs.juliahub.com/CompatHelper/GCWpz/2.0.1/#Instructions-for-setting-up-the-SSH-deploy-key).

