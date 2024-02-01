### Quick reference

#### Installer [Ansible]

```bash
sudo apt update
sudo apt install -y python3-{dev,pip,venv} sshpass

python3 -m venv venv
source venv/bin/activate
python -m pip install -U pip
python -m pip install -r requirements.txt
ansible --version

ansible-galaxy install -r requirements.yml
```

[Ansible]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

#### Generer scripts for maskinen du sitter på:
```bash
# Generer script uten å installere
ansible-playbook generate.yml -e skip_handlers=true

# Generer script og installer alt
ansible-playbook generate.yml

# Generer script for en annen versjon
ansible-playbook generate.yml -e skip_handlers=true --extra-vars ansible_distribution_major_version=20
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