#          IOST Development Environment
#         dApps Example Smart Contracts
    

  1.  setup admin account with admin sub account
  ```
  iwallet account import admin 2yquS3ySrGWPEKywCPzX4RTJugqRh7kJSo5aehsLYPEWkUxBWA39oMrZ7ZxuM4fgyXYs2cPwh5n8aNNpH5x2VyK1
  ```

  2.  publish the smart contract and ABI, take note of the Contract ID
  ```
  iwallet --server localhost:30002 --account admin --chain_id 1020 publish HelloWorld.js HelloWorld.abi
  ``` 

  3.  call or execute the contract using the Contract ID from above
  ```
  iwallet --server localhost:30002 --account admin --chain_id 1020 call "Contract96YFqvomoAnX6Zyj993fkv29D2HVfm8cjGhCEM1ymXGf" "hello" '["developer"]'
  ```

