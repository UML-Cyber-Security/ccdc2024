
Using GPG for Vault Initialization Keys
1. Generate GPG Key Pair for Vault Initialization

# Generate a GPG key pair for Vault initialization
``gpg --full-generate-key``

Follow the prompts to provide details for the GPG key pair.
2. Export GPG Public Key



# Export GPG public key
`` gpg --export --armor > gpg_public.key``

3. Initialize Vault with GPG Public Key



# Initialize Vault using GPG public key for unseal keys
``vault operator init -pgp-keys="file://gpg_public.key"``

Follow the prompts to unseal and initialize Vault. The GPG key will be used for encrypting the unseal keys.
4. Unseal Vault with GPG Private Key



# Unseal Vault using GPG private key
`` echo "Enter GPG private key passphrase: " ``
`` read -s passphrase ``
`` vault operator unseal -migrate -pgp-keys="file://gpg_private.key" -migrate-passphrase="$passphrase" ``

Replace gpg_private.key with the path to your GPG private key.
5. Access Vault using GPG Unseal Keys


# Access Vault after unsealing
`` echo "Enter GPG private key passphrase: " ``
`` read -s passphrase ``
`` vault login -method=pgp key=$passphrase ``


# Note:
You can turn the commands into a bash scrip
!#bang
This script logs into Vault using the GPG key, and you will be prompted for the GPG private key passphrase.