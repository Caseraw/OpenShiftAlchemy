# Certificates Directory

This directory is used to store SSL/TLS certificates and private keys required for secure communication.

## Required Files
- `cert.pem`: The SSL/TLS certificate.
- `key.pem`: The private key associated with the certificate.
- (Optional) `ca.pem`: The Certificate Authority (CA) certificate if required.

## Instructions
1. Obtain or generate the required certificate and key.
   - To generate a self-signed certificate, you can use:
     ```sh
     openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
     ```
2. Place `cert.pem`, `key.pem`, and (if needed) `ca.pem` in this directory.
3. Ensure the private key has the correct permissions:
   ```sh
   chmod 600 key.pem
   ```

## Security Notice
- **Never commit `cert.pem`, `key.pem`, or `ca.pem` to the repository.** These files are ignored by Git to prevent accidental exposure.
- **Keep private keys (`key.pem`) secure.** Do not share them or upload them to public repositories.
- **Consider using a secrets management tool** to store and manage certificates securely.
