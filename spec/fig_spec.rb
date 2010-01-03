require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'open3'
require 'fileutils'

FIG_HOME = File.expand_path(File.dirname(__FILE__) + '/../tmp/fighome')
FileUtils.mkdir_p(FIG_HOME)
ENV['FIG_HOME'] = FIG_HOME

FIG_REMOTE_DIR = File.expand_path(File.dirname(__FILE__) + '/../tmp/remote')
FileUtils.mkdir_p(FIG_REMOTE_DIR)
ENV['FIG_REMOTE_URL'] = "ssh://localhost#{FIG_REMOTE_DIR}"
puts ENV['FIG_REMOTE_URL']

FIG_EXE = File.expand_path(File.dirname(__FILE__) + '/../bin/fig')

def fig(args, input=nil)
  args = "--input - #{args}" if input
  stdin, stdout, stderr = Open3.popen3("#{FIG_EXE} #{args}")
  if input
    stdin.puts input
    stdin.close
  end
  return stdout.read.strip, stderr.read.strip
end

describe "Fig" do
  it "set environment variable from command line" do
    fig('-s FOO=BAR -g FOO')[0].should == 'BAR'
    fig('--set FOO=BAR -g FOO')[0].should == 'BAR'
  end

  it "set environment variable from fig file" do
    input = <<-END
      config default
        set FOO=BAR
      end
    END
    fig('-g FOO', input)[0].should == 'BAR'
  end

  it "append environment variable from command line" do
    fig('-p PATH=foo -g PATH').should == ["#{ENV['PATH']}#{File::PATH_SEPARATOR}foo",""]
  end

  it "append environment variable from fig file" do
    input = <<-END
      config default
        append PATH=foo
      end
    END
    fig('-g PATH', input).should == ["#{ENV['PATH']}#{File::PATH_SEPARATOR}foo",""]
  end

  it "append empty environment variable" do
    fig('-p XYZZY=foo -g XYZZY').should == ["foo",""]
  end

  it "publish to remote repository" do
    FileUtils.rm_rf(FIG_HOME)
    FileUtils.rm_rf(FIG_REMOTE_DIR)
    input = <<-END
      config default
        set FOO=BAR
      end
    END
    puts fig('--publish foo/1.2.3', input)
    fig('-u -i foo/1.2.3 -g FOO')[0].should == 'BAR'
  end

  it "publish resource to remote repository" do
    FileUtils.rm_rf(FIG_HOME)
    FileUtils.rm_rf(FIG_REMOTE_DIR)
    FileUtils.mkdir_p("tmp/bin")
    File.open("tmp/bin/hello", "w") { |f| f << "echo bar" }
    fail unless system "chmod +x tmp/bin/hello"
    input = <<-END
      resource tmp/bin/hello
      config default
        append PATH=@/tmp/bin
      end
    END
    puts fig('--publish foo/1.2.3', input)
    fig('-u -i foo/1.2.3 -- hello')[0].should == 'bar'
  end

  it "retrieve resource" do
    FileUtils.rm_rf(FIG_HOME)
    FileUtils.rm_rf(FIG_REMOTE_DIR)
    FileUtils.mkdir_p("tmp/lib")
    File.open("tmp/lib/hello", "w") { |f| f << "some library" }
    input = <<-END
      resource lib/hello
      config default
        append FOOPATH=@/tmp/lib/hello
      end
    END
    puts fig('--publish foo/1.2.3', input)
    input = <<-END
      retrieve FOOPATH->tmp/lib/[package]"
      config default
        include foo/1.2.3
      end
    END
    fig('-u')
    File.read("tmp/lib/hello").should == "some library"
  end
end
