#!/bin/bash
#
# Copyright (C) 20113 Erick Birbe <erickcion@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

# Directorio del script
PWD=$(dirname $0)
# Determinar la arquitectura
ARQUITECTURA=$(dpkg --print-architecture)
# Directorio temporal para trabajar
DIR_TEMP="/tmp/ffx_erickcion"
# Directorio de instalacion
DIR_INST="/opt/erickcion"

exit_error()
{
	echo "
Ocurrio un error!

:-(

Presione ENTER para salir..."
	read x
	exit 1
}

# Crear el directorio temporal
if [ ! -d $DIR_TEMP ]; then
	mkdir -p $DIR_TEMP
fi

# Determinar la URL de descarga
if [ $ARQUITECTURA == "i386" ]; then
	FFX_URL="http://download.cdn.mozilla.net/pub/mozilla.org/firefox/releases/latest/linux-i686/es-ES"
	TDB_URL="http://download.cdn.mozilla.net/pub/mozilla.org/thunderbird/releases/latest/linux-i686/es-ES"
elif [ $ARQUITECTURA == "amd64" ]; then
	FFX_URL="http://download.cdn.mozilla.net/pub/mozilla.org/firefox/releases/latest/linux-x86_64/es-ES"
	TDB_URL="http://download.cdn.mozilla.net/pub/mozilla.org/thunderbird/releases/latest/linux-x86_64/es-ES"
else
	echo "Esta aqruitectura no es reconocida por este script"
	exit_error
fi

# Ruta firefox
rm -f "$DIR_TEMP/es-ES"
if ! wget $FFX_URL -P $DIR_TEMP; then
	exit_error
fi
FFX_FILE=$(sed -ne '/firefox.*\.tar\.bz2/s/.*<a href="\([^"]*\)".*/\1/p' $DIR_TEMP/es-ES)
# Ruta thunderbird
rm -f "$DIR_TEMP/es-ES"
if ! wget $TDB_URL -P $DIR_TEMP; then
	exit_error
fi
TDB_FILE=$(sed -ne '/thunderbird.*\.tar\.bz2/s/.*<a href="\([^"]*\)".*/\1/p' $DIR_TEMP/es-ES)


# Descargar la version mas reciente de firefox
if ! wget -c $FFX_URL/$FFX_FILE -P $DIR_TEMP; then
	exit_error
fi
# Descargar la version mas reciente de thunderbird
if ! wget -c $TDB_URL/$TDB_FILE -P $DIR_TEMP; then
	exit_error
fi

# Extraer comprimido en directorio de instalacion
if [ ! -d $DIR_INST ]; then
	mkdir -p $DIR_INST
fi
if ! tar -xvf $DIR_TEMP/$FFX_FILE -C $DIR_INST; then
	exit_error
fi
if ! tar -xvf $DIR_TEMP/$TDB_FILE -C $DIR_INST; then
	exit_error
fi

# Dar permisos publicos a los archivos para permitir
# las actualizaciones automaticas
chmod -R a+u $DIR_INST

# Instalando ejecutables
ln -fs "$DIR_INST/firefox/firefox" "/usr/bin/firefox"
ln -fs "$DIR_INST/thunderbird/thunderbird" "/usr/bin/thunderbird"

# Desactivar cunaguaro
if [ -e "/usr/bin/cunaguaro" ]; then
	rm "/usr/bin/cunaguaro"
	ln -fs "/usr/bin/firefox" "/usr/bin/cunaguaro"
fi
# Desactivar guacharo
if [ -e "/usr/bin/guacharo" ]; then
	rm "/usr/bin/guacharo"
	ln -fs "/usr/bin/thunderbird" "/usr/bin/guacharo"
fi

# Crear iconos en el menu
cp -f "$PWD/firefox.desktop.in" "/usr/share/applications/firefox.desktop"
cp -f "$PWD/thunderbird.desktop.in" "/usr/share/applications/thunderbird.desktop"

# Actualizar menus
update-menus

# Confirmación y despedida
echo "
Mozilla-Canaima
===============

Terminamos, espero que haya salido todo bien.

Si deseas reportar un error por favor dirigete a la siguiente
direccion y describe lo mejor que puedas el problema:

    https://github.com/erickcion/mozilla-canaima/issues

INSTALACION FINALIZADA
Presiona ENTER para terminar..."
read dummy
