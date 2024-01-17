### Quick reference

#### Generer scripts for maskinen du sitter på:
```bash
ansible-playbook generate.yml

# Generer script uten å installere
ansible-playbook generate.yml -e skip_handlers=true
```
Endre filen `host_vars/localhost` for å tilpasse.

#### Installere oppsett på en vanilla Ubuntu labmaskin (ikke Jetson)

```bash
# Sjekk at filene ikke inneholder feil
ansible-lint setup.yml

# Kjør oppsettet (Installasjon av CUDA, og bygging av OpenCV tar lang tid)
ansible-playbook setup.yml -vv

# Bare noen utvalgte
ansible-playbook setup.yml --limit 'ITS-LAP01,ITS-LAP02'

# Untatt noen utvalgte
ansible-playbook setup.yml --limit '!ITS-LAP01,!ITS-LAP02'
```

#### Skru av alle maskiner

```bash
ansible-playbook shutdown.yml
```