package;

import haxe.io.Path;

using StringTools;

/**
 * @author Matthijs Kamstra aka [mck]
 */
class Main {
	var TARGET:String; // current target (neko, node.js, c++, c#, python, java)
	var ASSETS:String; // root folder of the website
	var EXPORT:String; // folder to generate files in (in this case `docs` folder from github )
	//
	var POSTS:String = 'posts';
	var PAGES:String = 'pages';
	//
	var settings:Dynamic; // should make this a typedef
	// collect all information
	var writeArr:Array<WriteFile> = [];
	var postArr:Array<WriteFile> = [];
	var pageArr:Array<WriteFile> = [];

	function new() {
		var startTime = Date.now().getTime(); // lets see how fast target really are

		TARGET = Sys.getCwd().split('bin/')[1].split('/')[0]; // yep, that works in this folder structure
		EXPORT = Path.normalize(Sys.getCwd().split('bin/')[0] + '/www/${TARGET}'); // normal situation this would we just the `www` or `docs` folder
		ASSETS = Path.normalize(Sys.getCwd().split('bin/')[0] + '/assets/');

		// create some general information/settings which can be used for template generation
		settings = {
			title: '[${TARGET}] minimal static site generator',
			footer: 'Copyright &copy; ${Date.now().getFullYear()} - [mck]'
		}

		trace('[${TARGET}] Creating a static site generator');

		collectData();
		writeFiles();
		writeIndex();
		writeCSS();

		trace('[${TARGET}] done in ${Std.int(Date.now().getTime() - startTime)}ms');
	}

	function collectData() {
		// pages / posts
		var folderArr = [PAGES, POSTS];
		for (i in 0...folderArr.length) {
			var folderName = folderArr[i];
			var folder = Path.normalize(ASSETS + '/${folderName}');
			var filesOrFoldersArray = sys.FileSystem.readDirectory(folder);
			for (i in 0...filesOrFoldersArray.length) {
				// lets assume everyting is a file
				var file = filesOrFoldersArray[i];
				// get the name of the file
				var fileName = Path.withoutExtension(file);
				// get content of the file
				var fileContent:String = sys.io.File.getContent(folder + "/" + file);
				// collect
				var writeFile = new WriteFile(folderName, fileName, fileContent);
				writeArr.push(writeFile);
				if (folderName == POSTS) {
					postArr.push(writeFile);
				} else {
					pageArr.push(writeFile);
				}
			}
		}
	}

	function writeFiles() {
		for (i in 0...writeArr.length) {
			var file:WriteFile = writeArr[i];
			// get path to export folder (`www` or `docs`)
			var path = Path.normalize(EXPORT + '/' + file.folderName);
			// write
			writeHtml(path, file.fileName, Markdown.markdownToHtml(file.fileContent));
		}
	}

	function writeIndex() {
		var posts = [];
		for (i in 0...postArr.length) {
			var writeFile = postArr[i];
			posts.push(writeFile.toObj());
		}
		var str = '
		::foreach posts::
		<div class="container">
::markdownShort::
			<a class="btn btn-outline-dark" href="::folderName::/::fileName::.html" role="button">::fileName::</a>
		</div>
		<hr>
		::end::
		';

		var template = new haxe.Template(str);
		var output = template.execute({posts: posts});

		// we need to wrap the content
		var html = '<!doctype html>\n<html lang="en">\n${createHead(EXPORT)}\n<body>\n${createNavigation(EXPORT)}\n<main rol="main" class="container">\n${output}\n</main>\n${createFooter()}\n</body>\n</html>';
		// write the file
		sys.io.File.saveContent(EXPORT + '/index.html', html);
		trace('written file: ${EXPORT}/index.html');
	}

	function writeCSS() {
		var css = '
html { position: relative; min-height: 100%; }
body { margin-bottom: 60px;  padding-top:4.5rem;}
.footer {  position: absolute; bottom: 0; width: 100%;  height: 60px; line-height: 60px; background-color: #f5f5f5;}
';
		sys.io.File.saveContent(EXPORT + '/default.css', css);
	}

	/**
	 * simply write the files
	 * @param path 		folder to write the files (current assumption is `EXPORT`)
	 * @param filename	the file name (without extension)
	 * @param content	what to write to the file (in our case markdown)
	 */
	function writeHtml(path:String, filename:String, content:String) {
		if (!sys.FileSystem.exists(path)) {
			sys.FileSystem.createDirectory(path);
		}
		// we need to wrap the content
		var html = '<!doctype html>\n<html lang="en">\n${createHead(path)}\n<body>\n${createNavigation(path)}\n<main rol="main" class="container">\n${content}\n</main>\n${createFooter()}\n</body>\n</html>';
		// write the file
		sys.io.File.saveContent(path + '/${filename}.html', html);
		trace('written file: ${path}/${filename}.html');
	}

	function createHead(path:String):String {
		var folder = path.replace(EXPORT, ''); // remove absolute data
		var arr = folder.split('/'); // create array based upon `/`
		var temp = '';
		for (i in 0...arr.length - 1) {
			temp += '../';
		}
		var path = Path.normalize(temp + 'default.css');
		var str = '<head>
			<!-- Required meta tags -->
			<meta charset="utf-8">
			<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
			<!-- Bootstrap CSS -->
			<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
			<title>::title::</title>
			<!-- Drop-In Alternative for Font Awesome Icons: https://ficons.fiction.com/ -->
			<link href="https://cdn.jsdelivr.net/npm/ficons@1.1.52/dist/ficons/font.css" rel="stylesheet">
			<!-- custom style -->
			<link href="${path}" rel="stylesheet">
		</head>';
		var template = new haxe.Template(str.replace('\t', ''));
		var output = template.execute(settings);
		return output;
	}

	/**
	 * perhaps better to store this somewhere
	 * @return String
	 */
	function createNavigation(path:String):String {
		var folder = path.replace(EXPORT, ''); // remove absolute data
		var root = folder;
		if(root != '') root = '../';
		var pages = [];
		var posts = [];
		var str = '<header>\n<!-- header/navigation -->';
		str += '\n<!--';
		str += '\npages:';
		for (i in 0...pageArr.length) {
			var writeFile = pageArr[i];
			var obj = writeFile.toObj();
			if (folder.indexOf(PAGES) != -1) {
				str += '\n\t-  <a href="${writeFile.fileName}.html">${writeFile.fileName}</a>';
				Reflect.setField(obj, 'path', '${writeFile.fileName}.html');
			} else {
				str += '\n\t-  <a href="${root}${writeFile.folderName}/${writeFile.fileName}.html">${writeFile.fileName}</a>';
				Reflect.setField(obj, 'path', '${root}${writeFile.folderName}/${writeFile.fileName}.html');
			}
			pages.push(obj);
		}
		str += '\nposts:';
		for (i in 0...postArr.length) {
			var writeFile = postArr[i];
			var obj = writeFile.toObj();
			if (folder.indexOf(POSTS) != -1) {
				str += '\n\t-  <a href="${writeFile.fileName}.html">${writeFile.fileName}</a>';
				Reflect.setField(obj, 'path', '${writeFile.fileName}.html');
			} else {
				str += '\n\t-  <a href="${root}${writeFile.folderName}/${writeFile.fileName}.html">${writeFile.fileName}</a>';
				Reflect.setField(obj, 'path', '${root}${writeFile.folderName}/${writeFile.fileName}.html');
			}
			posts.push(obj);
		}
		str += '\n-->';

		str += '\n
		<nav class="navbar navbar-expand-md navbar-dark fixed-top bg-dark">
		<div class="container">
		<a class="navbar-brand" href="${root}"><i class="fa fa-gears"></i></a>
		<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
		<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarCollapse">
		<ul class="navbar-nav mr-auto">
			::foreach pages::
			<li class="nav-item">
				<a class="nav-link" href="::path::">::fileName::</a>
			</li>
			::end::
		</ul>
		</div>
		</div>
		</nav>
		';
		str += '\n</header>';

		var template = new haxe.Template(str.replace('\t', ''));
		var output = template.execute({pages: pages});
		return output;
	}

	function createFooter():String {
		var str = '<footer class="footer">
		<div class="container">
		<span class="text-muted">::footer::</span>
		</div>
		</footer>
		<!-- Optional JavaScript -->
		<!-- jQuery first, then Popper.js, then Bootstrap JS -->
		<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
		<!-- Generated on: ${Date.now()} -->';
		var template = new haxe.Template(str.replace('\t', ''));
		var output = template.execute(settings);
		return output;
	}

	static public function main() {
		var main = new Main();
	}
}

class WriteFile {
	public var folderName:String;
	public var fileName:String;
	public var fileContent:String;
	public var markdown:String;
	public var markdownShort:String;

	/**
	 * [Description]
	 * @param folderName
	 * @param fileName
	 * @param fileContent
	 */
	public function new(folderName:String, fileName:String, fileContent:String) {
		this.folderName = folderName;
		this.fileName = fileName;
		this.fileContent = fileContent;
		this.markdown = Markdown.markdownToHtml(fileContent);
		this.markdownShort = Markdown.markdownToHtml(fileContent.substr(0, 200) + ' ...');
	}

	public function toObj():Dynamic {
		return {
			folderName: folderName,
			fileName: fileName,
			fileContent: fileContent,
			markdown: markdown,
			markdownShort: markdownShort
		};
	}

	public function toString():String {
		return '[WriteFile]';
	}
}
