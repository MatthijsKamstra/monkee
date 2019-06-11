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
		var path = Path.normalize(ASSETS + '/home.md');
		if (sys.FileSystem.exists(path)) {
			var md:String = sys.io.File.getContent(path);
			writeHtml(EXPORT, 'index', Markdown.markdownToHtml(md));
		} else {
			trace('ERROR: there is not file: $path');
		}
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
		var html = '<!doctype html>\n<html lang="en">\n${createHead()}\n<body>\n${createNavigation()}\n<main rol="main">\n${content}\n</main>\n${createFooter()}\n</body>\n</html>';
		// write the file
		sys.io.File.saveContent(path + '/${filename}.html', html);
		trace('written file: ${path}/${filename}.html');
	}

	function createHead():String {
		var str = '<head>
			<!-- Required meta tags -->
			<meta charset="utf-8">
			<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
			<!-- Bootstrap CSS -->
			<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
			<title>::title::</title>
		</head>';
		var template = new haxe.Template(str.replace('\t',''));
		var output = template.execute(settings);
		return output;
	}

	/**
	 * perhaps better to store this somewhere
	 * @return String
	 */
	function createNavigation():String {
		var str = '<header>\n<!-- navigation -->\n<!--';
		str += '\npages:';
		for (i in 0...pageArr.length) {
			var writeFile = pageArr[i];
			str += '\n\t-  <a href="${writeFile.folderName}/${writeFile.fileName}.html">${writeFile.fileName}</a>';
		}
		str += '\nposts:';
		for (i in 0...postArr.length) {
			var writeFile = postArr[i];
			str += '\n\t-  <a href="${writeFile.folderName}/${writeFile.fileName}.html">${writeFile.fileName}</a>';
		}
		str += '\n-->\n</header>';
		return str;
	}

	function createFooter():String {
		var str = '<footer>\n::footer::\n</footer>
		<!-- Optional JavaScript -->
		<!-- jQuery first, then Popper.js, then Bootstrap JS -->
		<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
		<!-- Generated on: ${Date.now()} -->';
		var template = new haxe.Template(str.replace('\t',''));
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
	}

	public function toString():String {
		return '[WriteFile]';
	}
}
