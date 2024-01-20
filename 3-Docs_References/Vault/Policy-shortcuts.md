
# About
Policies are typically used to define permissions in the HashiCorp vault
- Token: You can assign a policy to a token when created.
- Identity: You can assign a policy to an entity via the identity secret engine.
- Auth methods: Policy can be applied via an auth method.



list policies
`vault policy list`

Read speciic policy
`vault policy read <name-policy`

Create a new policy
`vault policy write <name-policy> <policy-config-file.hcl>`

Delete existing policy
``vault policy delete <name-policy>`` 




# When you create a policy you need to assign it to a token. 
- You have three options to assign a policy to a token.

You can assign a policy to a token directly when you create it.
``vault token create -policy=”k8s-policy”``

Assign a policity to an entity inside an identiy engine
``vault write identity/entity/user/firat policies=”k8s-policy”``


You can assign a policy to an authentication method.
``vault write auth/userpass/users/firat token_policies=”k8s-policy”``



