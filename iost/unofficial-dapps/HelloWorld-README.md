#          IOST Development Environment
##            dApps HelloWord Example
   
  Q:  What are the pre-requisites?
  A:  You can find them here:  https://iost.watch/

  Q:  What is the difference between a dApp and a Smart Contract?
  A:  

  Q:  How do we execute dApps?
  A:  

  Q:  What is the difference between MainNet, TestNet, and Test MainNet?
  A:  

  Q:
  A:   

  Q:
  A:   

  1.  We first create an account.  In this case, we will use 'admin' as the account name and use
      a test private key.  To run this on mainnet, you'll need an official IOST account and private 
      key.  This example assumes that you've installed a local node, started iServer, and run 
      tests to confirm the blockchain is working.  
  ```
  iwallet account import admin 2yquS3ySrGWPEKywCPzX4RTJugqRh7kJSo5aehsLYPEWkUxBWA39oMrZ7ZxuM4fgyXYs2cPwh5n8aNNpH5x2VyK1
  ```

  2.  Second we publish Application Binary Interface (ABI).  The ABI defines how we interact with the dApp inside
      the blockchain.  Two items to note, one is the chain_id and second is the Contract ID.  The chain_id 
      specifies wich blockchain to target as there are three of them:

      1024 - MainNet 
      1023 - TestNet
      1020 - Test MainNet
  
      You should not run a MainNet (1024) for testing and debugging.  Currently the IOST Unofficial setup is set to 1020
      so you will be fine.

  ```
  iwallet --server localhost:30002 --account admin --chain_id 1020 publish HelloWorld.js HelloWorld.abi
  ``` 

  3.  call or execute the contract using the Contract ID from above
  ```
  iwallet --server localhost:30002 --account admin --chain_id 1020 call "Contract96YFqvomoAnX6Zyj993fkv29D2HVfm8cjGhCEM1ymXGf" "hello" '["developer"]'
  ```

