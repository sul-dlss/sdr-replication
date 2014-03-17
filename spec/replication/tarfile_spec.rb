require_relative '../spec_helper'

# Unit tests for class {Replication::Tarfile}
describe 'Replication::Tarfile' do
  
  before(:all) do
    @tmpdir = Pathname(Dir.mktmpdir("tarfile"))
  end

  after(:all) do
    @tmpdir.rmtree if @tmpdir.exist?
  end

  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Replication::Tarfile#initialize}
    # Which returns an instance of: [Replication::Tarfile]
    # For input parameters:
    # * options [Hash<Symbol,Object>] = Key,Value pairs specifying initial values of attributes 
    specify 'Replication::Tarfile#initialize' do
       
      # test initialization with required parameters (if any)
      tarfile = Tarfile.new
      expect(tarfile).to be_instance_of(Tarfile)
      expect(tarfile.format).to eq(:posix)
      expect(tarfile.dereference).to eq(true)
      expect(tarfile.verify).to eq(false)
      expect(tarfile.multi_volume).to eq(false)
      options = {
          format: :gnu,
          dereference: false,
          verify: true,
          multi_volume: true
      }
      tarfile = Tarfile.new(options)
      expect(tarfile.format).to eq(:gnu)
      expect(tarfile.dereference).to eq(false)
      expect(tarfile.verify).to eq(true)
      expect(tarfile.multi_volume).to eq(true)
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      @tarfile = Tarfile.new
    end
    
    # Unit test for attribute: {Replication::Tarfile#format}
    # Which stores: [String] create archive of the specified format
    specify 'Replication::Tarfile#format' do
      value = 'Test format'
      @tarfile.format = value
      expect(@tarfile.format).to eq(value)
    end
    
    # Unit test for attribute: {Replication::Tarfile#dereference}
    # Which stores: [Boolean] Follow symlinks and archive the files they point to
    specify 'Replication::Tarfile#dereference' do
      value = :maybe
      @tarfile.dereference= value
      expect(@tarfile.dereference).to eq(value)
    end
    
    # Unit test for attribute: {Replication::Tarfile#verify}
    # Which stores: [Boolean] Verify that files were copied faithfully
    specify 'Replication::Tarfile#verify' do
      value = :maybe
      @tarfile.verify= value
      expect(@tarfile.verify).to eq(value)
    end
    
    # Unit test for attribute: {Replication::Tarfile#multi_volume}
    # Which stores: [Boolean] Create/list/extract multi-volume archive (not yet implemented)
    specify 'Replication::Tarfile#multi_volume' do
      value = :maybe
      @tarfile.multi_volume= value
      expect(@tarfile.multi_volume).to eq(value)
    end

    # Unit test for method: {Replication::Tarfile#tarfile_basepath}
    # Which returns: [Pathname] The full path of the ancestor dir in which the tar file resides
    # For input parameters: (None)
    specify 'Replication::Tarfile#tarfile_basepath' do
      basepath = Pathname.new('/test/basepath')
      @tarfile.tarfile_basepath=(basepath)
      expect(@tarfile.tarfile_basepath).to eq(basepath)
    end

    # Unit test for method: {Replication::Tarfile#tarfile_fullpath}
    # Which returns: [Pathname] the full path of the tar archive file to be created or extracted from
    # For input parameters: (None)
    specify 'Replication::Tarfile#tarfile_fullpath' do
      fullpath = Pathname.new('/test/fullpath')
      @tarfile.tarfile_fullpath=(fullpath)
      expect(@tarfile.tarfile_fullpath).to eq(fullpath)
    end
    
    # Unit test for method: {Replication::Tarfile#tarfile_relative_path}
    # Which returns: [String] The id (path relative to basepath) of the tar file
    # For input parameters: (None)
    specify 'Replication::Tarfile#tarfile_relative_path' do
      @tarfile.tarfile_basepath=("/my/base")
      @tarfile.tarfile_fullpath=("/my/base/relative/path")
      expect(@tarfile.tarfile_relative_path.to_s).to eq('relative/path')
    end
    
    # Unit test for method: {Replication::Tarfile#source_fullpath}
    # Which returns: [Pathname] The full path of the source file or directory being archived
    # For input parameters: (None)
    specify 'Replication::Tarfile#source_fullpath' do
      source = Pathname.new('/test/source')
      @tarfile.source_fullpath=(source)
      expect(@tarfile.source_fullpath).to eq(source)
    end
    
    # Unit test for method: {Replication::Tarfile#source_basepath}
    # Which returns: [Pathname] The directory that is the basis of relative paths
    # For input parameters: (None)
    specify 'Replication::Tarfile#source_basepath' do
      base = Pathname.new('/test/base')
      @tarfile.source_basepath=(base)
      expect(@tarfile.source_basepath).to eq(base)
    end

    # Unit test for method: {Replication::Tarfile#source_relative_path}
    # Which returns: [Pathname] The relative path from the source base directory to the source directory
    # For input parameters: (None)
    specify 'Replication::Tarfile#source_relative_path' do
      @tarfile.source_basepath=('/my/base')
      @tarfile.source_fullpath=('/my/base/relative/path')
      expect(@tarfile.source_relative_path.to_s).to  eq('relative/path')
    end
    
  end

  describe '=========================== INSTANCE METHODS ===========================' do

    before(:all) do
      @tarfile = Tarfile.new
      @tarfile.tarfile_basepath=@tmpdir
      @tarfile.tarfile_fullpath=@tmpdir.join('jq937jp0017-v0003.tar')
      @tarfile.source_basepath=@fixtures.join('moab-objects')
      @tarfile.source_fullpath=@fixtures.join('moab-objects/jq937jp0017/v0003')
    end

    # Unit test for method: {Replication::Tarfile#create_cmd}
    # Which returns: [String] The shell command string to be used to create the tarfile
    # For input parameters: (None)
    specify 'Replication::Tarfile#create_cmd' do
      expect(@tarfile.create_cmd).to eq(
         "tar --create --file=#{@tmpdir.join('jq937jp0017-v0003.tar')} --format=posix --dereference --directory='#{@tarfile.source_basepath}' jq937jp0017/v0003"
      )
    end
    
    # Unit test for method: {Replication::Tarfile#create_tarfile}
    # Which returns: [Tarfile] Shell out to the operating system and create the tar archive file
    # For input parameters: (None)
    specify 'Replication::Tarfile#create_tarfile' do
      @tarfile.create_tarfile
      expect(@tarfile.list_cmd).to eq("tar --list --file=#{@tmpdir.join('jq937jp0017-v0003.tar')} ")
      #puts @tarfile.list_tarfile
      expect(@tarfile.list_tarfile).to eq(<<-EOF
jq937jp0017/v0003/
jq937jp0017/v0003/data/
jq937jp0017/v0003/manifests/
jq937jp0017/v0003/manifests/fileInventoryDifference.xml
jq937jp0017/v0003/manifests/manifestInventory.xml
jq937jp0017/v0003/manifests/signatureCatalog.xml
jq937jp0017/v0003/manifests/versionAdditions.xml
jq937jp0017/v0003/manifests/versionInventory.xml
jq937jp0017/v0003/data/content/
jq937jp0017/v0003/data/metadata/
jq937jp0017/v0003/data/metadata/contentMetadata.xml
jq937jp0017/v0003/data/metadata/provenanceMetadata.xml
jq937jp0017/v0003/data/metadata/versionMetadata.xml
jq937jp0017/v0003/data/content/page-2.jpg
      EOF
      )
    end

    specify 'Replication::Tarfile#extract_tarfile' do
      target = @tmpdir.join('extract_dir')
      target.mkpath
      @tarfile.target_pathname = target
      expect(@tarfile.extract_cmd).to eq("tar --extract --file=#{@tmpdir.join('jq937jp0017-v0003.tar')} --directory='#{target}' ")
      @tarfile.extract_tarfile
      filelist = target.find.map{|f| f.relative_path_from(target).to_s}
      #ap filelist, options = {index: false}
      expect(filelist).to eq([
          ".",
          "jq937jp0017",
          "jq937jp0017/v0003",
          "jq937jp0017/v0003/data",
          "jq937jp0017/v0003/data/content",
          "jq937jp0017/v0003/data/content/page-2.jpg",
          "jq937jp0017/v0003/data/metadata",
          "jq937jp0017/v0003/data/metadata/contentMetadata.xml",
          "jq937jp0017/v0003/data/metadata/provenanceMetadata.xml",
          "jq937jp0017/v0003/data/metadata/versionMetadata.xml",
          "jq937jp0017/v0003/manifests",
          "jq937jp0017/v0003/manifests/fileInventoryDifference.xml",
          "jq937jp0017/v0003/manifests/manifestInventory.xml",
          "jq937jp0017/v0003/manifests/signatureCatalog.xml",
          "jq937jp0017/v0003/manifests/versionAdditions.xml",
          "jq937jp0017/v0003/manifests/versionInventory.xml"
      ])
    end

  end

end
