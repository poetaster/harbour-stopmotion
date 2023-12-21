Name:       harbour-stopmotion

# >> macros
%define _binary_payload w2.xzdio
%define __provides_exclude_from ^%{_datadir}/%{name}/lib/.*\\.so\\>
%define __requires_exclude_from ^%{_datadir}/%{name}/lib/.*\\.so\\>
%define __requires_exclude ^libc|libdl|libm|libpthread|libpython3.8m|libpython3.8m|python|env|libutil.*$
# << macros

Summary:       Stopmotion animation app
Version:       0.4.4
Release:       2
Group:         Qt/Qt
License:       GPLv3
URL:           http://github.com/poetaster/harbour-stopmotion
Source0:        %{name}-%{version}.tar.bz2
Requires:       sailfishsilica-qt5 >= 0.10.9
Requires:       pyotherside-qml-plugin-python3-qt5
Requires:       ffmpeg
Requires:       ffmpeg-tools
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.3
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Stopmotion takes time lapse photos to make stopmotion animations

%if "%{?vendor}" == "chum"
PackageName: Stopmotion
Type: desktop-application
Categories:
 - Video
 - Graphics
DeveloperName: Mark Washeim
Custom:
 - Repo: https://github.com/poetaster/harbour-stopmotion
Icon: https://raw.githubusercontent.com/poetaster/harbour-stopmotion/main/icons/172x172/harbour-stopmotion.png
Screenshots:
 - https://raw.githubusercontent.com/poetaster/harbour-stopmotion/main/screenshot-01.png
 - https://raw.githubusercontent.com/poetaster/harbour-stopmotion/main/screenshot-02.png
 - https://raw.githubusercontent.com/poetaster/harbour-stopmotion/main/screenshot-03.png
 - https://raw.githubusercontent.com/poetaster/harbour-stopmotion/main/screenshot-04.png
Url:
  Homepage: https://github.com/poetaster/harbour-stopmotion
  Donation: https://www.paypal.me/poetasterFOSS
%endif

%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qmake5 

make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# >> files
# << files
