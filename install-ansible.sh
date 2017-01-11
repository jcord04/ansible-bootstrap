#!/bin/sh
ANSIBLE_STABLE_BRANCH=stable-1.9

if [ "$(id -u)" != "0" ]; then
  echo "Sorry, this script must be run as root."
  exit 1
fi

while getopts ":b:c:d" opt; do
  case $opt in
    b)
      branch=$OPTARG
      ;;
    c)
      checkout=$OPTARG
      ;;
    d)
      ANSIBLE_DEBUG=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

which ansible > /dev/null 2>&1
if [ $? -eq 1 ]; then

  # echo "Installing Ansible build dependencies."
  # $ANSIBLE_DEBUG=1
  # if [ -z $ANSIBLE_DEBUG ]; then
  #   apt-get -qq --assume-yes update > /dev/null 2>&1
  #   apt-get -qq --assume-yes install build-essential libssl-dev libffi-dev
  #   apt-get -qq --assume-yes install git python-pip python-setuptools python-dev python-paramiko python-yaml python-jinja2 python-httplib2 python-passlib python-six python-ecdsa > /dev/null 2>&1
  #   #pip install --upgrade setuptools pip
  #   pip install cryptography
  # else
    apt-get --assume-yes update
    apt-get --assume-yes install build-essential autoconf libtool pkg-config libssl-dev libffi-dev python-dev libxml2-dev libxslt1-dev zlib1g-dev python-opengl python-imaging python-pyrex python-pyside.qtopengl qt4-dev-tools qt4-designer libqtgui4 libqtcore4 libqt4-xml libqt4-test libqt4-script libqt4-network libqt4-dbus python-qt4 python-qt4-gl libgle3
    apt-get --assume-yes install git python-pip python-setuptools python-paramiko python-yaml python-jinja2 python-httplib2 python-passlib python-six python-ecdsa
    #pip install --upgrade setuptools pip
    pip install cryptography
  # fi

  if [ -z $branch ] && [ ! -z $ANSIBLE_BRANCH ]; then
    echo "Setting branch from environment."
    branch=$ANSIBLE_BRANCH
  fi

  if [ -z $branch ]; then
    echo "Using default stable branch: $ANSIBLE_STABLE_BRANCH."
    branch="--branch $ANSIBLE_STABLE_BRANCH"
  else
    echo "Using $branch branch."
    branch="--branch $branch"
  fi

  ansible_dir=/usr/local/lib/ansible/
  if [ ! -d $ansible_dir ]; then
    echo "Cloning Ansible."
    if [ -z $ANSIBLE_DEBUG ]; then

      wget https://github.com/ansible/ansible/archive/stable-1.9.zip -O /usr/local/lib/ansible.zip
      unzip $ansible_dir/ansible.zip -d $ansible_dir/ansible
    else
      wget https://github.com/ansible/ansible/archive/stable-1.9.zip -O /usr/local/lib/ansible.zip
      unzip $ansible_dir/ansible.zip -d $ansible_dir/ansible
    fi
  fi

  # if [ -z $checkout ] && [ ! -z $ANSIBLE_CHECKOUT ]; then
  #   echo "Setting checkout target from environment."
  #   checkout=$ANSIBLE_CHECKOUT
  # fi

  # if [ ! -z $checkout ]; then
  #   echo "Checking out '$checkout'."
  #   cd $ansible_dir
  #   if [ -z $ANSIBLE_DEBUG ]; then
  #     git checkout $checkout --quiet
  #   else
  #     git checkout $checkout
  #   fi
  # fi

  echo "Running setups tasks for Ansible."
  cd $ansible_dir
  if [ -z $ANSIBLE_DEBUG ]; then
    python ./setup.py install > /dev/null 2>&1
  else
    python ./setup.py install
  fi

fi
