require 'facter'
Facter.add(:ec2tag_name) do
   setcode do
      Facter::Util::Resolution.exec("grep $(facter ec2_instance_id) /etc/puppet/ec2tag.txt |grep Name|awk '{print $3}'")
   end
end

