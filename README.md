### ANSIBLE AUTO DEPLOY HỆ THỐNG
## Các tags hiện  có
* install_gdnsd: Cài đặt gdnsd 2.3 lên server
* install_python: Cài đặt python 3.6.12 lên server
* install_logrotate: Cài đặt dnscap và setup logrotate trên server
# Bashscript:
```shell
chmod 755 run_install.sh
./run_install.sh <service>
```

        - Trong đó: 
                service: gdnsd hoặc python hoặc logrotate

- Bashscript đang dùng multipass để tạo server test
- Tự custom lại script nếu cần
