# vSphere

## Versioning

This plan works best with Terraform v0.12.0 and the vSphere provider v1.26.0. Newer versions tend to break the plan, ostensibly due to changes in the VMware API.

## Usage

To begin orchestrating VMs on vSphere, you need to first edit `vars.env`. Note that the template is untracked, so any changes you make will _not_ be tracked by Git.

1. `TF_VAR_vsphere_user`: The admin username for vSphere.
2. `TF_VAR_vsphere_password`: The admin user's password.
3. `TF_VAR_vsphere_server`: The IP address or hostname of the vSphere management server.
4. `TF_VAR_vsphere_datacenter`: The vSphere datacenter name.
5. `TF_VAR_vsphere_datastore`: The name of the datastore you'd like to place the VM's disk in.
6. `TF_VAR_vsphere_cluster`: The name of the vSphere cluster you'd like to run the VM in.
7. `TF_VAR_vsphere_network`: The name of the VMware network you'd like to use for the VM.
8. `TF_VAR_vsphere_template`: The template you wish to clone the VM from.
9. `TF_VAR_vsphere_host`: The host you wish to place the VM on.
10. `TF_VAR_vm_name`: The name of the VM, which will also be used as the hostname.
11. `TF_VAR_vm_guest`: The VMware Guest ID of the OS the VM will run. A list can be found [here](https://vdc-download.vmware.com/vmwb-repository/dcr-public/da47f910-60ac-438b-8b9b-6122f4d14524/16b7274a-bf8b-4b4c-a05e-746f2aa93c8c/doc/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html).
12. `TF_VAR_vm_domain`: A domain alias for the VM. 
13. `TF_VAR_vm_ip`: The IP address you'd like to set for the VM. Be careful, since this has to match with the IP range defined for the VLAN tagged to `TF_VAR_vsphere_network`.

Once you've updated these values, run `source vars.env`, then run `terraform plan` to check for any errors. If everything's green, go ahead and orchestrate the VM: `terraform apply`.


