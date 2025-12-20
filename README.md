# InitialProxmoxSetup
Начальное конфигурирование Proxmox Opentofu/Ansible
•	Установка Opentofu 
o	Загружаем установочный скрипт:
#curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
o	 Альтернатива: 
#wget --secure-protocol=TLSv1_2 --https-only https://get.opentofu.org/install-opentofu.sh -O install-opentofu.sh
o	Устанавливаем разрешение на выполнение:
#chmod +x install-opentofu.sh
o	Выполняем установку:
#./install-opentofu.sh --install-method deb
o	Удаляем скрипт установки:
#rm -f install-opentofu.sh
•	Настраиваем аутентификацию и авторизацию для подключения к Proxmox VE
Для аутентификации будем использовать API Token и SSH Connection.
o	создадим пользователя Proxmox:
#pveum user add tofu@pve 
o	создадим роль Proxmox для пользоватедя
#pveum role add Tofu -privs "Realm.AllocateUser, VM.PowerMgmt, VM.GuestAgent.Unrestricted, Sys.Console, Sys.Audit, Sys.AccessNetwork, VM.Config.Cloudinit, VM.Replicate, Pool.Allocate, SDN.Audit, Realm.Allocate, SDN.Use, Mapping.Modify, VM.Config.Memory, VM.GuestAgent.FileSystemMgmt, VM.Allocate, SDN.Allocate, VM.Console, VM.Clone, VM.Backup, Datastore.AllocateTemplate, VM.Snapshot, VM.Config.Network, Sys.Incoming, Sys.Modify, VM.Snapshot.Rollback, VM.Config.Disk, Datastore.Allocate, VM.Config.CPU, VM.Config.CDROM, Group.Allocate, Datastore.Audit, VM.Migrate, VM.GuestAgent.FileWrite, Mapping.Use, Datastore.AllocateSpace, Sys.Syslog, VM.Config.Options, Pool.Audit, User.Modify, VM.Config.HWType, VM.Audit, Sys.PowerMgmt, VM.GuestAgent.Audit, Mapping.Audit, VM.GuestAgent.FileRead, Permissions.Modify" 
o	назначим роль пользователю tofu@pve
#pveum aclmod / -user tofu@pve -role Tofu 
o	создадим API token для пользователя
#pveum user token add tofu@pve provider --privsep=0 tofu@pve!provider
o	сгенерируем пару клучей
#ssh-keygen 
o	копируем пару ключей в папку ~/virtualization/.ssh
cp ~/.ssh/id* ~/virtualization/.ssh
o	скопируем публичный ключ на узел Proxmox (192.168.1.100) для пользователя root
#ssh-copy-id root@192.168.1.100 
