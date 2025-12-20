# Initial Proxmox Setup
Начальное конфигурирование Proxmox Opentofu/Ansible.
Opentofu будет использоваться для создания ресурсов, а Ansible для настройки виртуальной машины и контейнера LXC
### Установка Opentofu 
```bash
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb
rm -f install-opentofu.sh
```
### Настраиваем аутентификацию и авторизацию для подключения к Proxmox VE
Для аутентификации будем использовать API Token и SSH Connection.
```bash
pveum user add tofu@pve
pveum role add Tofu -privs "Realm.AllocateUser, VM.PowerMgmt, VM.GuestAgent.Unrestricted, Sys.Console, Sys.Audit, Sys.AccessNetwork, VM.Config.Cloudinit, VM.Replicate, Pool.Allocate, SDN.Audit, Realm.Allocate, SDN.Use, Mapping.Modify, VM.Config.Memory, VM.GuestAgent.FileSystemMgmt, VM.Allocate, SDN.Allocate, VM.Console, VM.Clone, VM.Backup, Datastore.AllocateTemplate, VM.Snapshot, VM.Config.Network, Sys.Incoming, Sys.Modify, VM.Snapshot.Rollback, VM.Config.Disk, Datastore.Allocate, VM.Config.CPU, VM.Config.CDROM, Group.Allocate, Datastore.Audit, VM.Migrate, VM.GuestAgent.FileWrite, Mapping.Use, Datastore.AllocateSpace, Sys.Syslog, VM.Config.Options, Pool.Audit, User.Modify, VM.Config.HWType, VM.Audit, Sys.PowerMgmt, VM.GuestAgent.Audit, Mapping.Audit, VM.GuestAgent.FileRead, Permissions.Modify
pveum aclmod / -user tofu@pve -role Tofu
pveum user token add tofu@pve provider --privsep=0 tofu@pve!provider
ssh-keygen
ssh-copy-id root@pve
```
###	Установка Ansible (ubuntu)
```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```
### Инициализация Opentofu
В процессе инициализации, загружается и устанавливается провайдер bpg/proxmox. Создаётся файл состояния (state file), который отслеживает изменения инфраструктуры. Генерируется локальный кеш.
```bash
tofu init
```

### Изменения инфраструктуры
```bash
tofu apply
```


