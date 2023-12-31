# This is for the mac build or clean.
FRAMEWORK_PATH=$(HOME)/Library/Frameworks
APP_NAME=z26mac
ICONFILE=z26icon

# fast build with no optimization for convenient development
fast:
	clang -std=gnu99 -no-pie -Wall -DLINUX z26.c -o z26 -lSDL2 -lm
	strip z26

# -no-pie so we can double-click to launch on more distros
linux:
	gcc -std=gnu99 -no-pie -Wall -DLINUX -O3 z26.c -o z26 -lSDL2 -lm
	strip z26

debug:
	gcc -std=gnu99 -no-pie -Wall -DLINUX -g3 z26.c -o z26d -lSDL2 -lm

winfast:
#	windres z26.rc -O coff -o z26.res
	gcc -std=gnu99 -Wall -DWINDOWS z26.c -o z26.exe -lmingw32 -lSDL2main -lSDL2 -lm z26.res
	strip z26.exe

windows:
	windres z26.rc -O coff -o z26.res
	gcc -std=gnu99 -Wall -DWINDOWS -O3 z26.c -o z26.exe -lmingw32 -lSDL2main -lSDL2 -lm z26.res
	strip z26.exe

# https://joseph-long.com/writing/sdl-2-on-os-x-mavericks/
installsdl2mac:
	mkdir -p ~/Library/Frameworks
	cp -R /Volumes/SDL2/SDL2.framework ~/Library/Frameworks/
	codesign -f -s - ~/Library/Frameworks/SDL2.framework/SDL2

# https://joseph-long.com/writing/app-bundles-with-a-makefile/
mac:
	rm -f $(APP_NAME)
	rm -rf "./build/$(APP_NAME).app/"	
	clang -O3 -F "$(FRAMEWORK_PATH)" -DLINUX -DMAC -framework sdl2 z26.c -o $(APP_NAME) -lm
	mkdir -p "./build/$(APP_NAME).app"/Contents/{MacOS,Resources}
	cp -R "$(FRAMEWORK_PATH)/SDL2.framework" "./build/$(APP_NAME).app/Contents/Resources/"
	cp Info.plist "./build/$(APP_NAME).app/Contents/"
	cp $(ICONFILE).icns "./build/$(APP_NAME).app/Contents/Resources/"
	sed -e "s/APP_NAME/$(APP_NAME)/g" -i "" "./build/$(APP_NAME).app/Contents/Info.plist"
	sed -e "s/ICONFILE/$(ICONFILE)/g" -i "" "./build/$(APP_NAME).app/Contents/Info.plist"
	cp ./$(APP_NAME) "./build/$(APP_NAME).app/Contents/MacOS/$(APP_NAME)"

clean:
	rm -f z26 z26d

winclean:
	del z26.exe

macclean:
	rm -f $(APP_NAME)
	rm -rf "./build/$(APP_NAME).app/"
	rm -rf ./build
