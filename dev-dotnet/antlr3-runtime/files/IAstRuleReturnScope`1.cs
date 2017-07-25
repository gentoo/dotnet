namespace Antlr.Runtime
{
	/** <summary>AST rules have trees</summary> */
	public interface IAstRuleReturnScope<TAstLabel>
	{
		/** <summary>Has a value potentially if output=AST;</summary> */
		TAstLabel Tree {
			get;
		}
	}
}
