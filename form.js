'use strict';

// The GPU type field only applies to the g partition; hide it otherwise
// (submit.yml.erb ignores its value for other partitions). OnDemand 4 wraps
// each field in "#<field id>_wrapper" and hides with Bootstrap's d-none, the
// same way its own dynamic_forms.js toggleItemVisible() does.
function applyGpuTypeVisibility() {
  var isGpu = $('select[name$="[partition]"]').val() === 'g';
  var $gpuType = $('select[name$="[gpu_type]"]');
  $('#' + $gpuType.attr('id') + '_wrapper').toggleClass('d-none', !isGpu);
}

$(document).on('change', 'select[name$="[partition]"]', applyGpuTypeVisibility);
$(applyGpuTypeVisibility);
