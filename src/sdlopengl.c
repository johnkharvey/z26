/*
** sdlopengl.c -- opengl code
*/

dd texture_buffer[1280*1280];

#define INIT_ENTRY_POINT(funcname) \
_ ## funcname = SDL_GL_GetProcAddress(#funcname); \
if (!_ ## funcname) { printf("Couldn't get address of #funcname"); exit(1); }

void (APIENTRY* _glEnable)(GLenum);
void (APIENTRY* _glMatrixMode)(GLenum);
void (APIENTRY* _glOrtho)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble);
void (APIENTRY* _glViewport)(GLint, GLint, GLsizei, GLsizei);
void (APIENTRY* _glLoadIdentity)(void);
void (APIENTRY* _glBegin)(GLenum);
void (APIENTRY* _glEnd)(void);
void (APIENTRY* _glVertex2i)(GLint, GLint);
void (APIENTRY* _glTexCoord2i)(GLint, GLint);
void (APIENTRY* _glReadPixels)(GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, GLvoid*);
void (APIENTRY* _glPixelStorei)(GLenum, GLint);
void (APIENTRY* _glGenTextures)(GLsizei, GLuint*);
void (APIENTRY* _glDeleteTextures)(GLsizei, const GLuint*);
void (APIENTRY* _glBindTexture)(GLenum, GLuint);
void (APIENTRY* _glTexImage2D)(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, const GLvoid*);
void (APIENTRY* _glTexParameteri)(GLenum, GLenum, GLint);
void (APIENTRY* _glClearColor)(GLfloat, GLfloat, GLfloat, GLfloat);
void (APIENTRY* _glClear)(GLbitfield);

void init_glfuncs(void)
{	
	INIT_ENTRY_POINT(glEnable);
	INIT_ENTRY_POINT(glMatrixMode);
	INIT_ENTRY_POINT(glOrtho);
	INIT_ENTRY_POINT(glViewport);
	INIT_ENTRY_POINT(glLoadIdentity);
	INIT_ENTRY_POINT(glBegin);
	INIT_ENTRY_POINT(glEnd);
	INIT_ENTRY_POINT(glVertex2i);
	INIT_ENTRY_POINT(glTexCoord2i);
	INIT_ENTRY_POINT(glReadPixels);
	INIT_ENTRY_POINT(glPixelStorei);
	INIT_ENTRY_POINT(glGenTextures);
	INIT_ENTRY_POINT(glDeleteTextures);
	INIT_ENTRY_POINT(glBindTexture);
	INIT_ENTRY_POINT(glTexImage2D);
	INIT_ENTRY_POINT(glTexParameteri);
	INIT_ENTRY_POINT(glClearColor);
	INIT_ENTRY_POINT(glClear);
}

SDL_Window *window = NULL;
SDL_GLContext context;

void gl_InitOpenGL() {
	int flags = SDL_WINDOW_OPENGL;

	if (FullScreen) flags |= SDL_WINDOW_FULLSCREEN_DESKTOP;

	if (window) 
	{
		SDL_DestroyWindow(window);
		window = NULL;
	}

	if (SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER,1)<0)	// page-flipping needs double buffering
	{
		printf("Unable to set GL attribute : %s\n",SDL_GetError());
		exit(1);
	}

	window = SDL_CreateWindow("OpenGL Window", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 
								win_width, win_height, SDL_WINDOW_OPENGL);

	if (!window) 
	{
	    fprintf(stderr, "Couldn't create window: %s\n", SDL_GetError());
	    exit(1);
	}

	context = SDL_GL_CreateContext(window);
	if (!context) 
	{
	    fprintf(stderr, "Couldn't create context: %s\n", SDL_GetError());
	    exit(1);
	}

	if (SDL_GL_SetSwapInterval(Vsync))	/* 0  = immediate updates */
										/* 1  = sync with vertical retrace */
										/* -1 = adaptive */
	{
		fprintf(stderr, "Couldn't set swap interval.\n");
	}

	if (SDL_GL_LoadLibrary(NULL)<0)
	{
		printf("Unable to dynamically open GL lib : %s\n",SDL_GetError());
		exit(1);
	}

	init_glfuncs();
}

void gl_CreateScreen() {
	int hpos=0, vpos=0, hsize=0, vsize=0;
	int i;

	for (i=100; i>=1; i--)		// should work up to 32000x25600 resolution
		if ((screen_width >= i*320) && (screen_height >= i*256))
		{
			hsize = (i*320*width_adjust)/100;
			vsize = i*256;
			break;
		}

	_glEnable( GL_TEXTURE_2D );
	_glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );

	vpos = (screen_height - vsize)/2;
	hpos = (screen_width - hsize)/2;

	_glViewport( hpos, vpos, hsize, vsize );
	_glMatrixMode( GL_PROJECTION );
	_glLoadIdentity();
	_glOrtho( 0, (screen_width/2)*320/256, screen_height, 0, -1, 1 );
	_glMatrixMode( GL_MODELVIEW );
	_glLoadIdentity();
}

void gl_DrawScreen() {
	GLuint texture;

	_glClear( GL_COLOR_BUFFER_BIT );
	_glGenTextures(1, &texture);
	_glBindTexture( GL_TEXTURE_2D, texture );

	if ((VideoMode == 0) || (VideoMode == 2) || (VideoMode == 4)) {
		_glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
		_glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
		}
	else {
		_glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
		_glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	}

	_glTexImage2D( GL_TEXTURE_2D, 0, 3, tex_width, tex_height, 0, GL_BGRA, GL_UNSIGNED_BYTE, texture_buffer );
	
	_glBegin( GL_QUADS );
	_glTexCoord2i( 0, 0 );
	_glVertex2i( 0, 0 );
	_glTexCoord2i( 1, 0 );
	_glVertex2i( screen_width, 0 );
	_glTexCoord2i( 1, 1 );
	_glVertex2i( screen_width, screen_height );
	_glTexCoord2i( 0, 1);
	_glVertex2i( 0, screen_height );
	_glEnd();
	
	_glDeleteTextures(1, &texture );
}


/**
** z26 is Copyright 1997-2019 by John Saeger and contributors.  
** z26 is released subject to the terms and conditions of the 
** GNU General Public License Version 2 (GPL).	z26 comes with no warranty.
** Please see COPYING.TXT for details.
*/