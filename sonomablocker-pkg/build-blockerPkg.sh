#!/bin/zsh

# MARK: Constants

# package
pkgname="sonomablocker"
version="20230920"
identifier="dk.envo-it.${pkgname}"
install_location="/"
signature="Developer ID Installer: ENVO IT AS (FXW6QXBFW5)"

# notarization
dev_keychain_label="notary-envoit"

#setup some folders
dir=$(dirname ${0:A})

# MARK: build a pkg
echo "# building installer package"

payloadfolder="$dir/payload"
scriptsfolder="$dir/scripts"

# build the component package
pkgpath="${dir}/${pkgname}.pkg"

pkgbuild --root "${payloadfolder}" \
		 --scripts "${scriptsfolder}" \
		 --identifier "${identifier}" \
		 --version "${version}" \
		 --install-location "${install_location}" \
		 "${pkgpath}"

# NOTE: build the product archive

productpath="${dir}/${pkgname}-${version}.pkg"

productbuild --package "${pkgpath}" \
			 --version "${version}" \
			 --identifier "${identifier}" \
			 --sign "${signature}" \
			 "${productpath}"

# clean the component pkgname
rm "$pkgpath"


# MARK: notarize

# upload for notarization
notaryResult=$(xcrun notarytool submit "$productpath" --keychain-profile "$dev_keychain_label" --wait)

echo $notaryResult

if [[ "$(echo "$notaryResult" | tail -1 | grep "status:" | cut -d ":" -f2)" == " Invalid" ]]; then
	notaryId=$(echo "$notaryResult" | tail -2 | grep "id:" | cut -d ":" -f2 | tr -d '[:space:]')
	xcrun notarytool log $notaryId --keychain-profile "$dev_keychain_label"
fi

# NOTE: staple result
echo "# Stapling $productpath"
xcrun stapler staple "$productpath"

exit $exit_code
