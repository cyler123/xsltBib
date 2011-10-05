use strict;
use utf8;
#use warnings;
no warnings;
use feature ':5.12';

use XML::DOM;
use BibTeX::Parser;
use IO::File;
use Getopt::Long;
use File::Path;
use File::Spec::Functions;
use File::Basename;
our $texfile="";
our $generateBib=0;
my $options_okay=GetOptions(
		   'texfile|file|f=s'=>\$texfile,
		   'generatebib|g|bib'=>\$generateBib,
		   
);
#命令行解析错误则退出
die "Syntax Error!Check Your Command Line" unless ($options_okay);

say "Now processing ",$texfile;

#把文件名改为同名的.AUX文件
$texfile=~s/\.tex$/\.aux/i;
#如果文件不存在或者为空的话
die "File Is Inexistent or Size is Zero" unless -s $texfile;
#打开文件
my $AuxFileHandle=IO::File->new($texfile) or die "Fail To Open $texfile,$!";

our @entryKeyList;
our $bibData="";
our $xsltFile="";
#逐行处理文件
my $citeRegex=qr/^\\citation\{(.+)\}$/i;
my $bibRegex=qr/^\\bibdata\{(.+)\}$/i;
my $xsltRegex=qr/^\\bibstyle\{(.+)\}$/i;
while(my $AuxLine=<$AuxFileHandle>){
	#\cite条目
	push @entryKeyList,split(/,/,$1) if($AuxLine=~$citeRegex);
	#bib文件
	$bibData=$1 if($AuxLine=~$bibRegex);
	#xslt文件
	$xsltFile=$1 if ($AuxLine=~$xsltRegex);
}
#关闭Aux文件句柄
close($AuxFileHandle);
#bib文件是否存在
$bibData.=".bib";
die "$bibData is Inexistent or Size is Zero" if not -s $bibData;

#打开.bib文件
my $bibFileHandle=IO::File->new($bibData) or die "Can't Open $bibData,$1";
#parse bib文件
my $bibParser=BibTeX::Parser->new($bibFileHandle);
#把bib整个读入内存
my %entryHash;
@entryHash{@entryKeyList}=undef;
while(my $entry=$bibParser->next){
	if($entry->parse_ok and exists $entryHash{$entry->key}){
		$entryHash{$entry->key}=$entry;
#		say $entry->field("title");
	}
}
#输出总共的cite数目
say "Totally ",scalar keys %entryHash," cites";

#开始输出XML文件
##生成根节点
my $XMLParser=new XML::DOM::Parser;
my $DOM=$XMLParser->parse("<bibliography />");

foreach my $entryKey (@entryKeyList){
	if(defined $entryHash{$entryKey}){
	  ENTRY:
		my $entry=$entryHash{$entryKey};
		my $entryNode=$DOM->createElement("entry");
		$entryNode->setAttribute("type",$entry->type);
		$entryNode->setAttribute("key",$entry->key);
		#添加Authors节点
		my $authorListNode=$DOM->createElement("authors");
	  AUTHOR:
		#添加每一个作者
		my $short="";
		foreach my $author ($entry->author){
			my $authorNode=$DOM->createElement("author");
			my $firstName=$DOM->createElement("first");
			$firstName->setAttribute("short",join('~',map({uc(substr($_,0,1))} split(/\s+|-+/,$author->first))));
			$firstName->appendChild($DOM->createTextNode($author->first));
			$authorNode->appendChild($firstName);
			my $vonName=$DOM->createElement("von");
			$vonName->setAttribute("short",join('~',map({uc(substr($_,0,1))} split(/\s+|-+/,$author->von))));
			$vonName->appendChild($DOM->createTextNode($author->von));
			$authorNode->appendChild($vonName);
			my $lastName=$DOM->createElement("last");
			$lastName->setAttribute("short",join('~',map({uc(substr($_,0,1))} split(/\s+|-+/,$author->last))));
			$lastName->appendChild($DOM->createTextNode($author->last));
			$authorNode->appendChild($lastName);
			my $jrName=$DOM->createElement("jr");
			$jrName->setAttribute("short",join('~',map({uc(substr($_,0,1))} split(/\s+|-+/,$author->jr))));
			$jrName->appendChild($DOM->createTextNode($author->jr));
			$authorNode->appendChild($jrName);

			$authorListNode->appendChild($authorNode);
		}
		$entryNode->appendChild($authorListNode);
		#是否有编辑信息
	  EDITOR:
		if($entry->has("editor")){
			my $editorListNode=$DOM->createElement("editors");
			foreach my $author ($entry->author){
				my $editorNode=$DOM->createElement("editor");

				my $firstName=$DOM->createElement("first");
				$firstName->setAttribute("short",join('~',map({uc(substr($_,0,1))} split(/\s+|-+/,$author->first))));
				$firstName->appendChild($DOM->createTextNode($author->first));
				$editorNode->appendChild($firstName);
				my $vonName=$DOM->createElement("von");
				$vonName->setAttribute("short",join('~',map({uc(substr($_,0,1))} split(/\s+|-+/,$author->von))));
				$vonName->appendChild($DOM->createTextNode($author->von));
				$editorNode->appendChild($vonName);
				my $lastName=$DOM->createElement("last");
				$lastName->setAttribute("short",join('~',map({uc(substr($_,0,1))} split(/\s+|-+/,$author->last))));
				$lastName->appendChild($DOM->createTextNode($author->last));
				$editorNode->appendChild($lastName);
				my $jrName=$DOM->createElement("jr");
				$jrName->setAttribute("short",join('~',map({uc(substr($_,0,1))} split(/\s+|-+/,$author->jr))));
				$jrName->appendChild($DOM->createTextNode($author->jr));
				$editorNode->appendChild($jrName);
				$editorListNode->appendChild($editorNode);
			}
			$entryNode->appendChild($editorListNode);
		}

	  TITLE_AND_OTHER:
		#添加标题
		foreach my $fieldName ($entry->fieldlist()){
			if(index("author,editor,",$fieldName)<0){
				my $fieldNode=$DOM->createElement($fieldName);
				$fieldNode->appendChild($DOM->createTextNode($entry->field($fieldName)));
				$entryNode->appendChild($fieldNode);
			}
		}
	  ENTRY_END:
		#条目分析结束，把分析过的部分置为undef
		$entryHash{$entryKey}=undef;
		$DOM->getDocumentElement->appendChild($entryNode);
	}
}
XML_OUT_PUT:
#打印到XML文件
$texfile=~s/\.aux$/\.xml/i;
say "Generate XML File $texfile";
$DOM->printToFile($texfile);
say "Your XSLT File is $xsltFile";
die "Can't Open XSLT,$!" unless -s $xsltFile;


