package generator

import (
	"fmt"

	"android/soong/android"
)

func bootleggersExpandVariables(ctx android.ModuleContext, in string) string {
	bootleggersVars := ctx.Config().VendorConfig("bootleggersVarsPlugin")

	out, err := android.Expand(in, func(name string) (string, error) {
		if bootleggersVars.IsSet(name) {
			return bootleggersVars.String(name), nil
		}
		// This variable is not for us, restore what the original
		// variable string will have looked like for an Expand
		// that comes later.
		return fmt.Sprintf("$(%s)", name), nil
	})

	if err != nil {
		ctx.PropertyErrorf("%s: %s", in, err.Error())
		return ""
	}

	return out
}
