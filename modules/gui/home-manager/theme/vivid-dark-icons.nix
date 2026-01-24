{ stdenv }:

stdenv.mkDerivation rec {
  pname = "Vivid-Dark-Icons";
  version = "1.0.1";
  src = ./Vivid-Dark-Icons.tar.gz;
  dontBuild = true;

  # Remove missing target links
  preFixup = ''
    rm $out/share/icons/Vivid-Dark-Icons/mimetypes/16/application-vnd.oasis.opendocument.spreadsheet.svg
    rm $out/share/icons/Vivid-Dark-Icons/mimetypes/16/text-vnd.wap.wml.svg
    rm $out/share/icons/Vivid-Dark-Icons/mimetypes/16/application-vnd.oasis.opendocument.text-template.svg
    rm $out/share/icons/Vivid-Dark-Icons/mimetypes/16/libreoffice-oasis-text-template.svg
    rm $out/share/icons/Vivid-Dark-Icons/mimetypes/16/libreoffice-oasis-spreadsheet.svg
    rm $out/share/icons/Vivid-Dark-Icons/mimetypes/16/application-vnd.oasis.opendocument.text-master.svg
    rm $out/share/icons/Vivid-Dark-Icons/mimetypes/16/libreoffice-oasis-text.svg
    rm $out/share/icons/Vivid-Dark-Icons/mimetypes/16/text-x-dtd.svg
    rm $out/share/icons/Vivid-Dark-Icons/mimetypes/16/libreoffice-text-template.svg
    rm $out/share/icons/Vivid-Dark-Icons/mimetypes/16/libreoffice-spreadsheet.svg
    rm $out/share/icons/Vivid-Dark-Icons/mimetypes/16/libreoffice-text.svg
  '';
  installPhase = ''
    mkdir -p $out/share/icons/Vivid-Dark-Icons
    tar -xzf $src -C $out/share/icons/
  '';
}
